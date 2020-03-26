({
    loadModel : function(component, event) {
        
        var _this = this;
        var actionName = "c.getMetadata";
        var param = {};
        _this.callAction(component, actionName, param, function(response){
            var resultData = [];
            resultData.push("Select the Template");
            for (var i = 0; i < response.metadataList.length; i++) {
                resultData.push(response.metadataList[i]);
            }
            
            component.set("v.options",resultData);
        });
    },
    
    getTemplateBody : function(component, event) {
        
        var _this = this;
        var actionName = "c.getTextMetadata";
        var param = {
            "text" : component.get("v.selectedTemplate")
        };
        _this.callAction(component, actionName, param, function(response){
            var body = response.templateBody;
            //alert(resultData);
            component.set("v.textValue",body);
        });
    },
    
    createTask : function(component, event, userValue) {
        
        //Show Spinner
        component.set("v.showSpinnerForTask", true);
        
        var _this = this;
        var actionName = "c.saveTask";;
        var param = {            
            "subject" : component.get("v.subject"),
            "noteBody" : component.get("v.description"),
            "rush" : component.get("v.rush"),
            "dueDate" : component.get("v.duedate"),
            "assignmentGroup" : component.get("v.assignmentGroupValueSelected"),
            "taskType" : component.get("v.taskTypeValueSelected"),
            "notes" : component.get("v.notes"),
            "assignToId" : userValue,
            "recordId" : component.get("v.recordId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                component.set("v.showSpinnerForTask", false);
                _this.userNotification("error", "Required Fields", response.userMessage);
            }else {
                _this.resetAttributes(component, event);
                _this.userNotification("success", "Success!", "The task has been created successfully.");
            	component.set("v.showRecordForm",false);
            }
        });        
    },
    
    createNote : function(component, event) {
        
        //Show spinner
        component.set("v.showSpinnerForNote", true);
        
        var _this = this;
        var actionName = "c.saveNotes";
        var param = {
            "noteTitle" : component.get("v.selectedTemplate"),
            "noteBody" : component.get("v.textValue"),
            "recordId" : component.get("v.recordId")
        };
        _this.callAction(component, actionName, param, function(response){
            if(!$A.util.isEmpty(response.userMessage)) {
                component.set("v.showSpinnerForNote", false);
                _this.userNotification("error", "Blank Template", response.userMessage);
            } else {
                component.set("v.showSpinnerForNote", false);
                _this.resetAttributes(component, event);
                _this.userNotification("success", "Success!", "The note has been created successfully.");
                console.log("Saved succesfully");
            }
        }); 
    },
    
	getPicklistValues : function(component, event) {
        component.set("v.showRecordForm",true);
		var _this = this;
        var actionName = "c.getPicklistValues";
        var param = {};
        _this.callAction(component, actionName, param, function(response){
            console.log(response.assignmentGrouptoptions);
            var assignmentGroupValues = response.assignmentGrouptoptions;
            var taskTypeValues = response.dependentPicklistValues[assignmentGroupValues[0]];
            var queueMap = response.queueMap;
            console.log('taskTypeValues' + taskTypeValues);
            console.log('queueMap' + queueMap);
            
            //Create option list
            var assignmentGroupOpts = _this.createOptionList(assignmentGroupValues);
            var taskTypeOpts = _this.createOptionList(taskTypeValues);
            var queueOpts = _this.mapToOptionList(queueMap);
            
            //Set picklist values on the UI
            component.set("v.dependentPicklistMap", response.dependentPicklistValues);
            component.set("v.assignmentGroupOptions", assignmentGroupOpts);
            component.set("v.taskTypeOptions", taskTypeOpts);
            component.set("v.queueOptions", queueOpts);
            
            //Get value from template and assign it to description on Task
            var templateBody = component.get("v.textValue");
            component.set("v.description", templateBody);
            
            //Get value from template and assign it to subject on Task
            var taskSubject = component.get("v.selectedTemplate");
            component.set("v.subject", taskSubject);
        });
	},
    
    getDependentPicklist : function (component, event) {
        var _this = this;
        var depOpts = [];
        var dependentPicklistMap = component.get("v.dependentPicklistMap");
        var selectedValue = component.get("v.assignmentGroupValueSelected");
        var depOptionList = dependentPicklistMap[selectedValue];
        console.log("dependentMap in getDependentPicklist = " + depOptionList);
        
        if(depOptionList !== undefined) {
            depOpts = _this.createOptionList(depOptionList);
            component.set("v.taskTypeOptions", depOpts);
            component.set("v.taskTypeValueSelected", depOpts[0].value);
            component.find("taskType").set("v.disabled", false);
            
        } else {
            component.set("v.taskTypeOptions", null);
            component.set("v.taskTypeValueSelected", '');
            component.find("taskType").set("v.disabled", true);
        }        
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
        console.log("queueMap in mapToOptionList = " + queueMap);
        
        optionList.push({
            class: "optionClass",
            label: "",
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
    
    saveTask : function(component, event){
        var _this = this;
        var userValue;
        var assignTo = component.get("v.assignTo");
        
        if(assignTo == "User") {
            event.preventDefault();
        	const fields = event.getParam('fields');
        	console.log('Fields = ' + fields);
        	userValue = fields.ROAE_User__c;
        	console.log('User = ' + userValue);
        } else if(assignTo == "Queue") {
            userValue = component.get("v.queueSelected");
        }
        _this.createTask(component, event, userValue);
        
    },
    
    dispalyAssignTo : function(component, event) {
        var assignTo = component.get("v.assignTo");
        console.log("assignTo = " + assignTo);
        if(assignTo == "User") {
            component.set("v.showUser", true);
            component.set("v.showQueue", false);
            component.set("v.showButton", false);
        }else if(assignTo == "Queue"){
            component.set("v.showUser", false);
            component.set("v.showQueue", true);
            component.set("v.showButton", true);
        }else {
            component.set("v.showUser", false);
            component.set("v.showQueue", false);
            component.set("v.showButton", true);
        }
    },
    
    populateTemplate : function(component, event) {
        var _this = this;
        //Template selected on child component
        var tempSelected = event.getParam("templateSelected");
        var showChildComp = event.getParam("showChildComp");
        console.log("Event value received = " + tempSelected);
        
        component.set("v.callChildComp", showChildComp);
        component.set("v.selectedTemplate", tempSelected);
        _this.getTemplateBody(component, event);
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
                    component.set("v.showSpinnerForNote", false);
                    component.set("v.showSpinnerForTask", false);
                    _this.userNotification('error','Failure!',ctrlResult.errorMessage);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Errors in callAction = " + message);
                }
                component.set("v.showSpinnerForNote", false);
                component.set("v.showSpinnerForTask", false);
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
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        toastEvent.fire();
    },
    
    resetAttributes : function(component, event) {
        component.set("v.subject", "");
        component.set("v.description", "");
        component.set("v.rush", false);
        component.set("v.duedate", null);
        component.set("v.assignmentGroupValueSelected", "");
        component.set("v.assignmentGroupOptions", "");
        component.set("v.taskTypeValueSelected", "");
        component.set("v.taskTypeOptions", "");
        component.set("v.notes", "");
        component.set("v.assignTo", "");
        component.set("v.textValue", "");
        component.set("v.selectedTemplate", "");
        component.set("v.queueSelected", "")
        component.set("v.showUser", false);
        component.set("v.showQueue", false);
        component.set("v.showButton", true);
        component.set("v.showSpinnerForTask", false);
        component.set("v.showSpinnerForNote", false);
    }
})