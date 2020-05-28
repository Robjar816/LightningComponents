({
    getColumnAndAction : function(component, event) {
        var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'}
        ];
        
        var actionType = component.get("v.actionType");
        if(actionType == 'Update Field Action') {
            component.set('v.columns', [
                {label: 'Action Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}},
                {label: 'Object', fieldName: 'Object__c', type: 'text'},
                {label: 'Record Type', fieldName: 'Record_Type_Name__c', type: 'text'},
                {label: 'Field To Update', fieldName: 'Field_To_Update__c', type: 'text'},
                {label: 'New Value', fieldName: 'New_Value__c', type: 'text'},
                {type: 'action', typeAttributes: { rowActions: actions } } 
            ]);
        }else if(actionType == 'Send Email Action') {
            component.set('v.columns', [
                {label: 'Action Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}},
                {label: 'Record Type', fieldName: 'Record_Type_Name__c', type: 'text'},
                {label: 'Template Name', fieldName: 'Template_Name__c', type: 'text'},
                {label: 'Send Email From', fieldName: 'Send_Email_From__c', type: 'text'},
                {label: 'Send Email To', fieldName: 'Send_Email_To__c', type: 'text'},
                {label: 'Recipient\'s Email Address (If other)', fieldName: 'Recipient_s_Email_Address__c', type: 'text'},
                {type: 'action', typeAttributes: { rowActions: actions } } 
            ]);
        }else {
            component.set('v.columns', [
                {label: 'Action Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: {fieldName: 'Name', target: '_blank'}}},
                {label: 'Record Type', fieldName: 'Record_Type_Name__c', type: 'text'},
                {label: 'Survey Name', fieldName: 'Survey_Name__c', type: 'text'},                
                {label: 'Send Survey To', fieldName: 'Send_Survey_To__c', type: 'text'},
                {label: 'Recipient\'s Email Address (If other)', fieldName: 'Recipient_s_Email_Address__c', type: 'text'},
                {type: 'action', typeAttributes: { rowActions: actions } } 
            ]);
        }
        
    },
    
    getActions : function(component, event) {
        
        var action = component.get("c.getActions");
        var param = {
            "recordId" : component.get("v.recordId"),
            "recordType" : component.get("v.actionType")
        };
        
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionRecords = response.getReturnValue();
                console.log("Action records = " + actionRecords);
                actionRecords.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", actionRecords);
                component.set("v.totalRecords", actionRecords.length);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Errors in callAction = " + message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    editRecord : function(component, event) {
		var actionSelected = event.getParam('row');
        component.set("v.actionId", actionSelected.Id);
        component.set("v.editRecord", true);  
    },
    
    deleteRecord : function(component, event) {
		var actionSelected = event.getParam('row');
        component.set("v.actionId", actionSelected.Id);
        component.set("v.actionName", actionSelected.Name);
        component.set("v.deleteRecord", true);  
    },
    
    refreshDataTable: function(component, event) {
        var _this = this;
        component.set("v.showSpinner", true);
        _this.getActions(component, event);
        $A.get('e.force:refreshView').fire();
        
        var delayInMilliseconds = 600; //1 second
        setTimeout(function() {
            component.set("v.showSpinner", false);
        }, delayInMilliseconds);
    },
    
})