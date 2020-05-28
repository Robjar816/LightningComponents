({
	getCaseFieldList : function(component, event) {
        var _this = this;
        var actionName = "c.getCaseFields";
        var param = {
            "actionRecId" : component.get("v.actionId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                _this.userNotification("error", "Error", response.userMessage);
            } else {
                var fieldMap = response.fieldMap;
                var taskQueueMap = response.taskQueueMap;
                var caseQueueMap = response.caseQueueMap;
                var layoutMap = response.layoutMap;
                var actionRec = response.actionRecord;
                console.log("DoInIt: fieldMap = " + fieldMap);
                console.log("DoInIt: taskQueueMap = " + taskQueueMap);
                console.log("DoInIt: caseQueueMap = " + caseQueueMap);
                console.log("DoInIt: layoutMap = " + layoutMap);
                console.log("DoInIt: actionRec = " + actionRec);
                
                //Create option list
                var taskQueueOpts = _this.mapToOptionList(taskQueueMap);
                var caseQueueOpts = _this.mapToOptionList(caseQueueMap);    
                
                //Set queue options on component
                component.set("v.taskQueueOptions", taskQueueOpts);
                component.set("v.caseQueueOptions", caseQueueOpts);
                
                //Set maps on client side
                component.set("v.fieldMap", fieldMap);
                component.set("v.layoutMap", layoutMap);

				//Set action record data on component if not view/edit mode
                if(actionRec != undefined) {
                    component.set("v.actionName", actionRec.Name);
                    component.set("v.newValue", actionRec.New_Value__c);
                    //component.set("v.actionId", actionRec.Auto_Task__c);
                    if(!_this.ifEmptyOrUndefined(actionRec.Object__c)) {
                        component.set("v.objectToUpdate", actionRec.Object__c);
                        _this.objectChange(component, event);
                    }
                    if(!_this.ifEmptyOrUndefined(actionRec.Layout__c)) {
                        component.set("v.layoutSelected", actionRec.Layout__c);
                        _this.layoutChange(component,event);
                    }
                    if(!_this.ifEmptyOrUndefined(actionRec.Field_To_Update_API_Name__c)) {
                        component.set("v.fieldSelected", actionRec.Field_To_Update_API_Name__c);
                    }
                }
                
                //All attributes have been set
                component.set("v.showSpinner", false);
            }
        });
        
    },
    
    objectChange : function(component, event) {
        var _this = this;
        var objectToUpdate = component.get("v.objectToUpdate");
        var layoutMap = component.get("v.layoutMap");
        
        //If not empty, obtain layouts according to object selected 
        if(objectToUpdate !== ''){
            
            //Set layout options according to object selected
            var objectLayouts = layoutMap[objectToUpdate];
            if(objectLayouts !== undefined) {
                var objectLayoutOpts = _this.createOptionList(objectLayouts);
                component.set("v.layoutOptions", objectLayoutOpts);
                
                //Reset field to update
                component.set("v.fieldOptions", null);
                component.set("v.fieldSelected", '');
            }
            
            //Set queues on UI according to object selected 
            if(objectToUpdate == 'Case'){
                component.set("v.queueOptions", component.get("v.caseQueueOptions"));
            }else {
                component.set("v.queueOptions", component.get("v.taskQueueOptions"));
            }
           
        }else {
            component.set("v.layoutOptions", null);
            component.set("v.layoutSelected", '');
        }
        
    },
    
    //Layout selection changed. Update Field options
    layoutChange : function(component, event) {
        var _this = this;
        var objectToUpdate = component.get("v.objectToUpdate");
        var layoutSelected = component.get("v.layoutSelected");
        var fieldMap = component.get("v.fieldMap");
        
        //If not empty, obtain value(List of fields) from map 
        if(objectToUpdate !== '' && layoutSelected !== ''){
            var layoutName = objectToUpdate + '-' + layoutSelected;
            console.log("LayoutChange: layoutName = " + layoutName);
            var objectFields = fieldMap[layoutName];
            
            //Set fields on UI according to layout selected
            if(objectFields !== undefined) {
                var objectFieldOpts = _this.mapToOptionList(objectFields);
                component.set("v.fieldOptions", objectFieldOpts);
            }
        }
    },
    
    //Save Action
    saveAction : function(component, event) {
        //Show spinner
        component.set("v.showSpinner", true);
        
        var _this = this;
        var userMessage = 'The following required fields must be completed: ';
        var fieldsNotCompleted = '';
        var newActionName = component.get("v.actionName");
        var recordId = component.get("v.recordId");
        var objectToUpdate = component.get("v.objectToUpdate");
        var layoutSelected = component.get("v.layoutSelected");
        var fieldSelected = component.get("v.fieldSelected");
        var assignTo = component.get("v.assignTo");
        var queueSelected = component.get("v.queueSelected");
        var userId = component.get("v.userId");
        var newValue = component.get("v.newValue");
        var actionId = component.get("v.actionId");
        var editMode = component.get("v.editMode");
        
        //Check if all fields are populated
        fieldsNotCompleted += _this.checkRequiredFields(newActionName, recordId, objectToUpdate, layoutSelected,
                                                       fieldSelected, assignTo, queueSelected, userId, newValue);
        
        if(fieldsNotCompleted && editMode != true) {
            userMessage += fieldsNotCompleted;
            _this.userNotification('error','Complete Required Field(s)', userMessage);
            component.set("v.showSpinner", false);
        }else {
            //If "Owner ID" is "Field to Update", update new value field with queue/user ID
            if((fieldSelected == 'OwnerId' || fieldSelected == 'Assigned To ID')&& assignTo == 'Queue') {
                newValue = queueSelected;
            } else if((fieldSelected == 'OwnerId' || fieldSelected == 'Assigned To ID') && assignTo == 'User') {
                newValue = userId;
            }

            var actionName = "c.saveUpdateFieldAction";
            var param = {
                "newActionName" : newActionName,
                "autoTaskId" : recordId,
                "objectToUpdate" : objectToUpdate,
                "pageLayout" : layoutSelected,
                "fieldApiSelected" : fieldSelected,
                "newValue" : newValue,
                "actionRecId" : actionId,
                "editMode" : editMode
            };
            _this.callAction(component, actionName, param, function(response){
                if(!$A.util.isEmpty(response.userMessage)) {
                    _this.userNotification("error", "Error", response.userMessage);
                    component.set("v.showSpinner", false);
                } else {
                    if(editMode != true) {
                        _this.userNotification("success", "Success!", "Action has been created successfully!");
                        component.set("v.showSpinner", false);
                        $A.get("e.force:closeQuickAction").fire();
                        _this.createEventToRefreshDatatable(component,event);
                    	//$A.get('e.force:refreshView').fire();
                    }else {
                        _this.userNotification("success", "Success!", "Action has been updated successfully!");
                        component.set("v.showSpinner", false);
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
                    component.set("v.showSpinner", false);
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Errors in callAction = " + message);
                }
                _this.userNotification('error','Failure!','Failed to process data. Please contact System Administrator');
                component.set("v.showSpinner", false);
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
    
    //Converts List<String> to List<SelectOption>
    createOptionList : function(picklistValueList) {
        var optionList = [];
        if(picklistValueList != undefined && picklistValueList.length > 0){
            optionList.push({
                class: "optionClass",
                label: "",
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
    
    //Create error message if fields are not populated
    checkRequiredFields : function(newActionName, recordId, objectToUpdate, layoutSelected, fieldSelected, assignTo, queueSelected, userId, newValue) {
        
        var _this = this;
        var fieldsNotCompleted = '';
        
        if(_this.ifEmptyOrUndefined(newActionName))
            fieldsNotCompleted += 'Action Name, ';
        if(_this.ifEmptyOrUndefined(recordId))
            fieldsNotCompleted += 'Auto Task, ';
        if(_this.ifEmptyOrUndefined(objectToUpdate))
            fieldsNotCompleted += 'Object, ';
        if(_this.ifEmptyOrUndefined(layoutSelected))
            fieldsNotCompleted += 'Layout, ';
        if(_this.ifEmptyOrUndefined(fieldSelected))
            fieldsNotCompleted += 'Field To Update, ';
        if((fieldSelected == 'OwnerId' || fieldSelected == 'Assigned To ID') && _this.ifEmptyOrUndefined(assignTo))
            fieldsNotCompleted += 'Assign To, ';
        if((fieldSelected == 'OwnerId' || fieldSelected == 'Assigned To ID') && assignTo == 'Queue' &&_this.ifEmptyOrUndefined(queueSelected))
            fieldsNotCompleted += 'New Owner, ';
        if((fieldSelected == 'OwnerId' || fieldSelected == 'Assigned To ID') && assignTo == 'User' &&_this.ifEmptyOrUndefined(userId))
            fieldsNotCompleted += 'New Owner, ';
        if((fieldSelected != 'OwnerId' && fieldSelected != 'Assigned To ID') && _this.ifEmptyOrUndefined(newValue))
            fieldsNotCompleted += 'New Value, ';
        
        
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
})