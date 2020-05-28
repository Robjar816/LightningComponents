({
    getActionRecord : function(component, event) {
        var _this = this;
        var actionRecId = component.get("v.actionId");
        if(!_this.ifEmptyOrUndefined(actionRecId)) {
            var actionName = "c.getActionRecord";
            var param = {
                "actionRecId" : actionRecId
            };
            _this.callAction(component, actionName, param, function(response){
                if(!$A.util.isEmpty(response.userMessage)) {
                    _this.userNotification("error", "Error", response.userMessage);
                } else {
                    component.set("v.actionName", response.Name);
                    component.set("v.surveyName", response.Survey_Name__c);
                    component.set("v.sendSurveyTo", response.Send_Survey_To__c);
                    component.set("v.recipientsEmail", response.Recipient_s_Email_Address__c);
                }
            });
        }
        //All attributes have been set
        component.set("v.showSpinner", false);
    },
    
    saveAction : function(component, event) {
        var _this = this;
        var userMessage = '';
        
        var newActionName = component.get("v.actionName");
        var autoTaskId = component.get("v.recordId");
        var surveyName = component.get("v.surveyName");
        var sendSurveyTo = component.get("v.sendSurveyTo");
        var recipientsEmail = component.get("v.recipientsEmail");
        var actionId = component.get("v.actionId");
        var editMode = component.get("v.editMode")
        console.log("saveAction: newActionName = " + newActionName);
        console.log("saveAction: recordId = " + autoTaskId);
        console.log("saveAction: surveyName = " + surveyName);
        console.log("saveAction: sendSurveyTo = " + sendSurveyTo);
        console.log("saveAction: recipientsEmail = " + recipientsEmail);
        
        //Check if all fields are populated
        userMessage += _this.checkRequiredFields(newActionName, autoTaskId, surveyName, sendSurveyTo, recipientsEmail);
        
        if(userMessage) {
            _this.userNotification('error','Complete Required Field(s)', userMessage);
        }else {
            var actionName = "c.saveSendSurveyAction";
            var param = {
                "newActionName" : newActionName,
                "autoTaskId" : autoTaskId,
                "surveyName" : surveyName,
                "sendSurveyTo" : sendSurveyTo,
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
    checkRequiredFields : function(newActionName, recordId, surveyName, sendSurveyTo, recipientsEmail) {
        
        var _this = this;
        var userMessage = '';
        var fieldsNotCompleted = '';
        
        if(_this.ifEmptyOrUndefined(newActionName))
            fieldsNotCompleted += 'Action Name, ';
        if(_this.ifEmptyOrUndefined(recordId))
            fieldsNotCompleted += 'Auto Task, ';
        if(_this.ifEmptyOrUndefined(surveyName))
            fieldsNotCompleted += 'Survey Name, ';
		if(_this.ifEmptyOrUndefined(sendSurveyTo))
            fieldsNotCompleted += 'Send Survey To, ';
        if(sendSurveyTo == 'Other' && _this.ifEmptyOrUndefined(recipientsEmail))
            fieldsNotCompleted += 'Recipeint\'s Email Address, ';
        
        if(fieldsNotCompleted) {
            fieldsNotCompleted = fieldsNotCompleted.substring(0, fieldsNotCompleted.length-2);
            userMessage += 'The following required fields must be completed:' + fieldsNotCompleted;
        }     
        else if(!fieldsNotCompleted && !(_this.ifEmptyOrUndefined(recipientsEmail))) {
            var emailList = recipientsEmail.split(';');
            if(emailList.length > 1) {
                userMessage += 'Survey can only be sent to one recipient.'
            }
        }
        return userMessage;
    },
    
    //Returns true if string is empty or undefined
    ifEmptyOrUndefined : function(myString) {
        if(myString == undefined || myString == '') {
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
})