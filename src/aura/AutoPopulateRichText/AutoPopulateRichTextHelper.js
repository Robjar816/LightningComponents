({
	getTemplates : function(component, event) {
        var _this = this;
		var actionName = "c.getTemplates";
        var params = {};
        _this.callAction(component, actionName, params, function(response) {
            
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Required fields missing", response.userMessage);
            } else {
                component.set("v.templates", response.templateList);
                component.set("v.templateMap", response.templateMap);
                _this.setTemplateContent(component, event);
            }
        });
	},
    
    setTemplateContent : function(component, event) {
        var tempMap = component.get("v.templateMap");
        var tempSelected = component.get("v.templateSelected");
        var tempContent = tempMap[tempSelected];
        
        if(tempContent !== undefined) {
            component.set("v.inputText", tempContent);
        }        
    },
    
    saveNote : function(component, event) {
        var _this = this;
        var actionName = ("c.saveNote");
        var params = {
            "recordId": component.get("v.recordId"),
            "noteContent": component.get("v.inputText")
        };
        _this.callAction(component, actionName, params, function(response) {
             if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("Blank Template", "error", response.userMessage);
            } else {
                console.log("Saved succesfully");
                _this.userNotification("Success!", "success", "Note has been saved");
            }
        });
    },
    
    callAction: function(component, actionName, params, callback){  
        
        var _this = this;
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(_this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ctrlResult = response.getReturnValue();
                if(!ctrlResult.hasError) {
                    callback(ctrlResult);
                } else {
                    _this.userNotification('Failure!', 'error', ctrlResult.errorMessage);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                _this.userNotification('Failure!', 'error', 'Failed to process data. Please contact System Administrator');
            }
        });
        $A.enqueueAction(action);
    },
    
    //To display all error info for user.
    userNotification : function(infoHeader, infoVariant, infoMessage, errorMode, errorDuration) {
       
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: infoHeader,
            type: infoVariant,
            message: infoMessage
        });
        toastEvent.fire();
        //$A.get('e.force:refreshView').fire();
    },
})