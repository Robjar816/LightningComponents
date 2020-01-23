({
	checkConditions : function(component) {
		var _this = this;
        var actionName = "c.accInfo";
        var param = {
            "accId": component.get("v.recordId")
        };
        _this.callAction(component, actionName, param, function(response){
            var accRec = response.accRec;
            console.log("accRec = " + accRec);
            var currentUserId = $A.get("$SObjectType.CurrentUser.Id");
            if(accRec.Active__c != "Yes") {
                _this.userNotification("error", "Failure!", "Account must be approved.");
            } else if($A.util.isEmpty(accRec.Rating)) {
                _this.userNotification("error", "Failure!", "Rating is required if submitting for approval.");
            } else {
                _this.checkRequiredFields(component, component.get("v.recordId"));
            }
        })
	},
    
    //To validate if all required fields are filled before submitting for approval
    checkRequiredFields : function(component, recordId) {
        var _this = this;
        var actionName = "c.checkRequiredFields"; 
        var params = {
            "accId": recordId
        };
        _this.callAction(component, actionName, params, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Required fields missing", response.userMessage);
            } else {
                _this.userNotification("success", "Success!", "Record Submitted for Approval!");
            }
        }); 
    },
    
    //To display all error info for user.
    userNotification : function(infoVariant, infoHeader, infoMessage, errorMode, errorDuration) {
        var _this = this;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: infoHeader,
            type: infoVariant,
            message: infoMessage
        });
        $A.get("e.force:closeQuickAction").fire();
        toastEvent.fire();
    },
    
    //Used to get required Growth Opportunity info from the server
    callAction: function(component, actionName, params, callback){  
        var _this = this;
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ctrlResult = response.getReturnValue();
                if(!ctrlResult.hasError) {
                    callback(ctrlResult);
                } else {
                    _this.userNotification('error','Failure!',ctrlResult.errorMessage);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                _this.userNotification('error','Failure!','Failed to process data. Please contact System Administrator');
            }
        });
        $A.enqueueAction(action);
    },
})