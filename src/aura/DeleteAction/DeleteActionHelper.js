({
    deleteAction : function(component, event) {
        var _this = this;
        var actionName = "c.deleteAction";
        var param = {
            "recordId" : component.get("v.actionId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Error", response.userMessage);
            }else {
                _this.userNotification("success", "Success!", "Action was deleted.");
                _this.createEventToClose(component, event);
                
            }
        });
    },
    
    //To close parent component
    createEventToClose : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
        var sendEvent = component.getEvent("closeParentComponent");
        sendEvent.setParams({
        });
        sendEvent.fire();
        component.set("v.viewEditMode", false);
    },
    
    callAction : function(component, actionName, params, callback){  
        var _this = this;
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var ctrlResult = response.getReturnValue();
                if(!ctrlResult.hasError) {
                    callback(ctrlResult);
                } else {
                    _this.userNotification('error','Failure!',ctrlResult.errorMessage);
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Errors in callAction = " + message);
                }
                _this.userNotification('error','Failure!','Failed to process data. Please contact System Administrator');
            }
        });
        $A.enqueueAction(action);
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
        $A.get('e.force:refreshView').fire();
        toastEvent.fire();
    },
})