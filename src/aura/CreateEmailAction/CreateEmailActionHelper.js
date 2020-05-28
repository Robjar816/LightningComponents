({
    getDataForUI : function(component, event) {
        var _this = this;
        console.log("Action Id = " + component.get("v.actionId"));
        var actionName = "c.getOrgWideEmailsAndAction";
        var param = {
            "actionRecId" : component.get("v.actionId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Error", response.userMessage);
            } else {
                var orgWideEmails = response.orgWideEmails;
                var orgWideOptions = _this.createOptionList(orgWideEmails);
                component.set("v.orgWideOptions", orgWideOptions);
                
                var actionRec = response.actionRecord;
        		console.log("Action Record = " + actionRec);
                if(actionRec != undefined) {
                    component.set("v.actionName", actionRec.Name);
                    component.set("v.templateName", actionRec.Template_Name__c);
                    component.set("v.sendEmailFrom", actionRec.Send_Email_From__c);
                    component.set("v.sendEmailTo", actionRec.Send_Email_To__c);
                    component.set("v.recipientsEmail", actionRec.Recipient_s_Email_Address__c);
                }
            }
        });
        
        //All attributes have been set
        component.set("v.showSpinner", false);
    },
    
    saveAction : function(component, event) {
        var _this = this;
        var userMessage = 'The following required fields must be completed: ';
        var fieldsNotCompleted = '';
        
        var newActionName = component.get("v.actionName");
        var autoTaskId = component.get("v.recordId");
        var templateName = component.get("v.templateName");
        var sendEmailFrom = component.get("v.sendEmailFrom");
        var sendEmailTo = component.get("v.sendEmailTo");
        var recipientsEmail = component.get("v.recipientsEmail");
        var actionId = component.get("v.actionId");
        var editMode = component.get("v.editMode");
        console.log("saveAction: newActionName = " + newActionName);
        console.log("saveAction: autoTaskId = " + autoTaskId);
        console.log("saveAction: templateName = " + templateName);
        console.log("saveAction: sendEmailTo = " + sendEmailTo);
        console.log("saveAction: recipientsEmail = " + recipientsEmail);
        
        //Check if all fields are populated
        fieldsNotCompleted += _this.checkRequiredFields(newActionName, autoTaskId, templateName, sendEmailFrom, sendEmailTo, recipientsEmail);
        
        if(fieldsNotCompleted) {
            userMessage += fieldsNotCompleted;
            _this.userNotification('error','Complete Required Field(s)', userMessage);
        }else {
            var actionName = "c.saveSendEmailAction";
            var param = {
                "newActionName" : newActionName,
                "autoTaskId" : autoTaskId,
                "templateName" : templateName,
                "sendEmailFrom" : sendEmailFrom,
                "sendEmailTo" : sendEmailTo,
                "recipientsEmail" : recipientsEmail,
                "actionRecId" : actionId,
                "editMode" : editMode
            };
            _this.callAction(component, actionName, param, function(response){
                if(!$A.util.isEmpty(response.userMessage)) {
                    _this.userNotification("error", "Error", response.userMessage);
                } else {
                    if(editMode != true) {
                        _this.userNotification("success", "Success!", "Action has been created successfully!");
                        $A.get("e.force:closeQuickAction").fire();
                        _this.createEventToRefreshDatatable(component, event);
                    }else {
                        _this.userNotification("success", "Success!", "Action has been updated successfully!");
                        _this.createEventToClose(component, event);
                    }
                }
            });
        }
        
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
        //$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        toastEvent.fire();
    },
    //Create error message if fields are not populated
    checkRequiredFields : function(newActionName, recordId, templateName, sendEmailFrom, sendEmailTo, recipientsEmail) {
        
        var _this = this;
        var fieldsNotCompleted = '';
        
        if(_this.ifEmptyOrUndefined(newActionName))
            fieldsNotCompleted += 'Action Name, ';
        if(_this.ifEmptyOrUndefined(recordId))
            fieldsNotCompleted += 'Auto Task, ';
        if(_this.ifEmptyOrUndefined(templateName))
            fieldsNotCompleted += 'Template Name, ';
        if(_this.ifEmptyOrUndefined(sendEmailFrom))
            fieldsNotCompleted += 'Send Email From, ';
		if(_this.ifEmptyOrUndefined(sendEmailTo))
            fieldsNotCompleted += 'Send Email To, ';
        if(sendEmailTo == 'Other' && _this.ifEmptyOrUndefined(recipientsEmail))
            fieldsNotCompleted += 'Recipeint\'s Email Address, ';
        
        if(fieldsNotCompleted) {
            fieldsNotCompleted = fieldsNotCompleted.substring(0, fieldsNotCompleted.length-2);
        }
        return fieldsNotCompleted;
    },
    
    //Returns true if string is empty or undefined
    ifEmptyOrUndefined : function(myString) {
        if(myString == '' || myString == undefined) {
            return true;
        }
        return false;
    },
    
    //To close parent component
    createEventToClose : function(component, event) {
        var sendEvent = component.getEvent("closeParentComponent");
        sendEvent.setParams({
        });
        sendEvent.fire();
    },
    
    //To refresh datatable when new record is created
    createEventToRefreshDatatable : function(component, event) {
        var sendEvent = $A.get("e.c:RefreshDisplayActions");
        sendEvent.setParams({
        });
        sendEvent.fire();
    },
    
    //Converts List<String> to List<SelectOption>
    createOptionList : function(picklistValueList) {
        var optionList = [];
        if(picklistValueList != undefined && picklistValueList.length > 0){
            optionList.push({
                class: "optionClass",
                label: "--None--",
                value: ""
            });
        }
        
        for(var i = 0; i < picklistValueList.length; i++){
            optionList.push({
                class: "optionClass",
                label: picklistValueList[i],
                value: picklistValueList[i]
            });
        }
        return optionList;
    },
})