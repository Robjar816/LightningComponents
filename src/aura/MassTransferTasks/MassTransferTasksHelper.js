({
	getColumnAndAction : function(component, event) {
        var actions = [
            {label: 'View', name: 'view'} ,
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'}
        ];
        component.set('v.columns', [
            {label: 'Task Subject', fieldName: 'Subject', type: 'text'},
            {label: 'Assigned To', fieldName: 'OwnerId', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Assignment Group', fieldName: 'ROAE_Assignment_Group__c', type: 'text'},
            {label: 'Task Type', fieldName: 'ROAE_Task_Type__c', type: 'text'}
            //{type: 'action', typeAttributes: { rowActions: actions } }
        ]);
    },
    
    getActions : function(component, event) {
        
        var action = component.get("c.getTasks");
        var param = {
        };
        
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var taskRecords = response.getReturnValue();
                console.log("Task records = " + taskRecords);
                
                component.set("v.data", taskRecords);
                component.set("v.totalRecords", taskRecords.length);
                
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
})