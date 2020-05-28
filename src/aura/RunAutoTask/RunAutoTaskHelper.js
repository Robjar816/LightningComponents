({
	getAutoTaskList : function(component, event) {
        
        var _this = this;
        var actionName = "c.getAutoTasks";
        var param = {
            "caseRecordId": component.get("v.recordId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification(component, "error", "Error", response.userMessage);
            } else {
                var autoTaskMap = response.autoTaskMap;
                var taskMap = response.taskMap;
                
                //Create option list
                var autoTaskOpts = _this.mapToOptionList(autoTaskMap);
                var taskOpts = _this.mapToOptionList(taskMap);
                
                //Set picklist values on UI
                component.set("v.autoTaskOptions", autoTaskOpts);
                component.set("v.taskOptions", taskOpts);
            }
        });
        
    },
    
    runAutoTask : function(component, event) {
        var _this = this;
        if(component.get("v.autoTaskSelected") == '') {
            _this.userNotification(component, "error", "Select Auto Task", "Please select an Auto Task.");
        }else {
            var _this = this;
            var actionName = "c.getTaskAndRunAutoTask";
            var param = {
                "caseRecordId" : component.get("v.recordId"),
                "autoTaskSelectedId" : component.get("v.autoTaskSelected"),
                "taskToUpdateSelected" : component.get("v.taskSelected")
            };
            component.set("v.showSpinner", true);
            _this.callAction(component, actionName, param, function(response){
                if(!$A.util.isEmpty(response.userMessage)) {
                    _this.userNotification(component, "error", "Error", response.userMessage);
                } else {
                    _this.userNotification(component, "success", "Success!", "Auto task ran successfully.");
                    console.log("Saved succesfully");
                }
            });
        }
    },
    
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
                    _this.userNotification(component, 'error','Failure!',ctrlResult.errorMessage);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Errors in callAction = " + message);
                }
                _this.userNotification(component, 'error','Failure!','Failed to process data. Please contact System Administrator');
            }
        });
        $A.enqueueAction(action);
    },
    
    //To display all error info for user.
    userNotification : function(component, infoVariant, infoHeader, infoMessage, errorMode, errorDuration) {
        var _this = this;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: infoHeader,
            type: infoVariant,
            message: infoMessage
        });
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        toastEvent.fire();
        component.set("v.showSpinner", false);
    },
    
    //Converts a Map<String, String> to a List<SelectOption>
    mapToOptionList : function(queueMap) {
        var optionList = [];
        
        optionList.push({
            class: "optionClass",
            label: "--None--",
            value: ""
        });
        for(let [key, value] of Object.entries(queueMap)) {
            optionList.push({
                class: "optionClass",
                label: key,
                value: value
            });
        }
        return optionList;
    },
})