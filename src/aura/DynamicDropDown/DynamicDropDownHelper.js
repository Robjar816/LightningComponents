({
	getOptions : function(component, event) {
        
        var action = component.get("c.getOptions");
        var opts = [];
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                var controller = response.getReturnValue();
                var optionList = controller.options;
                var dependentMap = controller.dependentMap;
                console.log("OptionList = " + optionList);
                console.log("dependentMap = " + dependentMap);
                
                if(optionList.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "-- None --",
                        value: ""
                    });
                }
                for(var i = 0; i < optionList.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: optionList[i],
                        value: optionList[i]
                    });
                }
                component.set("v.dependentMap", dependentMap);
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
	},
    
    getDependentPicklist : function (component, event) {
        
        var dependentMap = component.get("v.dependentMap");
        var selectedValue = component.get("v.selectedValue");
        var dependentOptions = dependentMap[selectedValue];
        console.log("dependentMap in getDependentPicklist = " + dependentOptions);
        
        var depOpts = [];
        
        if(dependentOptions !== undefined) {
            var depOptionList = dependentOptions.split(";");            
            for(var i = 0; i < depOptionList.length; i++) {
                depOpts.push({
                    class: "optionClass",
                    label: depOptionList[i],
                    value: depOptionList[i]
                });
            }        
            component.set("v.dependentOptions", depOpts);
            component.set("v.dependentSelectedValue", depOpts[0].value);
            component.set("v.showDependentOptions", true);
        } else {
            component.set("v.dependentOptions", null);
            component.set("v.dependentSelectedValue", '');
        	component.set("v.showDependentOptions", false);
        }        
    },
    
    updateCaseStatus : function (component, event) {
        var _this= this;
        var actionName = "c.updateCaseStatus";
        var params = {
            "recordId": component.get("v.recordId"),
            "newValue": component.get("v.selectedValue"),
            "depNewValue": component.get("v.dependentSelectedValue")
        };
        console.log("Update Case Status = " + component.get("v.dependentSelectedValue"));
        
        _this.callAction(component, actionName, params, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Required fields missing", response.userMessage);
            } else {
                _this.userNotification("Success!", "success", "Case reason has been updated");
            }
        });
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
    
    //To display all error info for user.
    userNotification : function(infoHeader, infoVariant, infoMessage, errorMode, errorDuration) {
        var _this = this;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: infoHeader,
            type: infoVariant,
            message: infoMessage
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
    },
})