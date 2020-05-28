({
    getColumnAndAction : function(component, event) {
        var actions = [
            {label: 'Create Note', name: 'createNote', iconName: 'action:new_note'},
            {label: 'Create Task', name: 'createTask', iconName: 'action:new_task'}
        ];
        component.set('v.columns', [
            //{type: 'button', typeAttributes: {label: 'Select Template', name: 'templateSelected', iconName: 'action:check'}},
            {type: 'action', typeAttributes: { rowActions: actions } },
            {label: 'Template Name', fieldName: 'Name', type: 'text'},
            {label: 'Template Description', fieldName: 'ROAE_Description__c', type: 'text'} 
        ]);
    },
    
    //Get all templates
	getTemplates : function(component, event, pageNumber) {
        
        var action = component.get("c.getAllTemplates");
        var param = {
            "inputSearchText" : component.get("v.searchText")
        };
        
        action.setParams(param);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var paginationList = [];
                var resultTemplates = response.getReturnValue();
                console.log("Templates = " + resultTemplates);
                var pageSize = component.get("v.pageSize");
                var firstRecord = pageSize *(pageNumber - 1);
                //Total Records
                var totalRecords = resultTemplates.length;
                var lastRecord = pageSize * pageNumber;
                var recordEnd = totalRecords >= lastRecord ? lastRecord : totalRecords;
                
                for(var i = firstRecord; i < recordEnd; i++) {
                    paginationList.push(resultTemplates[i]);
                }
                
                component.set("v.templates", resultTemplates);
                component.set("v.filteredData", paginationList);
                component.set("v.totalRecords", totalRecords);
                component.set("v.recordStart", firstRecord + 1);
                //component.set("v.recordEnd", totalRecords >= recordEnd ? recordEnd : totalRecords);
                component.set("v.recordEnd", recordEnd);
                component.set("v.totalPages", Math.ceil(totalRecords/pageSize));
                component.set("v.pageNumber", pageNumber);
                
                
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
    
    //To send details of template selected to parent component.
    templateSelected : function(component, event, buttonClicked) {
        var templateSelected = event.getParam('row');
        console.log("templateSelected = " + templateSelected.Name);
        var sendEvent = component.getEvent("templateSelectedEvent");
        sendEvent.setParams({
            "templateSelected" : templateSelected.Name,
            "buttonClicked" : buttonClicked,
            "showChildComp" : false
        });
        sendEvent.fire();
        component.set("v.showModal", false);
    },
    
    closeModal : function(component, event) {
        component.set("v.showModal", false);
        //If mondal is closed, reset callChildComp in parent component
        var sendEvent = component.getEvent("templateSelectedEvent");
        sendEvent.setParams({"showChildComp" : false});
        sendEvent.fire();
    },
})