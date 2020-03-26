({
    getColumnAndAction : function(component) {
        var actions = [
            {label: 'View', name: 'view'} ,
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'}
        ];
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Body', fieldName: 'Non_HTML_Body__c', type: 'text'},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
    },
    getTemplates : function(component, helper) {
        var action = component.get("c.getCustomSettingsRecord");
        action.setParams({
            'templateName' : 'ABC',
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                for (var i = 0; i < resultData.length; i++) { 
                    resultData[i].Non_HTML_Body__c = resultData[i].Body__c.replace(/(<([^>]+)>)/ig,"");
                }
                component.set("v.filteredData", resultData);
            }
        });
        $A.enqueueAction(action);
    },
    viewRecord : function(component, event) {
        var row = event.getParam('row');
        component.set("v.recordView",row);
        component.set("v.showCreateLayout",true);
        component.set("v.showViewLayout",true);
        component.set("v.showNewLayout",false);
        component.set("v.showEditLayout",false);
        
    },
    deleteRecord : function(component, event) {
        var row = event.getParam('row');
        var action = component.get("c.deleteTemplate");
        action.setParams({
            'recId' : row
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                this.displayToastMessage("Success!","success","The record has been deleted successfully.");
            }else{
                this.displayToastMessage("failed!","error","The record has not been delete successfully.");
            }
        });
        $A.enqueueAction(action);
    },
    editRecord : function(component, event) {
        var row = event.getParam('row');
        
        component.set("v.selectedRecord",row);
        component.set("v.showCreateLayout",true);
        component.set("v.showViewLayout",false);
        component.set("v.showNewLayout",false);
        component.set("v.showEditLayout",true); 
        if(row == undefined || row == null){
            component.set("v.tname",component.get("v.recordView.Name"));
            component.set("v.tbody",component.get("v.recordView.Body__c"));
        }else{
            component.set("v.tname",row.Name);
            component.set("v.tbody",row.Body__c);
        }
    }, 
    updateTemplates : function(component, event){
        var row = component.get("v.selectedRecord");
        row.Name =  component.get("v.tname");
        row.Body__c = component.get("v.tbody");
        var action = component.get("c.updateTemplate");
        action.setParams({
            'recId' : row
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                //$A.get('e.force:refreshView').fire();
                this.displayToastMessage("Success!","success","The record has been updated successfully.");
            }else{
                var errors = response.getError();
                this.displayToastMessage("failed!","error","The record has not been deleted successfully.");
            }
        });
        $A.enqueueAction(action);
    }, 
    saveTemplates : function(component, event){
        var action = component.get("c.saveTemplate");
        
        var tempBody = component.get("v.tbody");
        var tempName = component.get("v.tname");
        
        action.setParams({
            'templateBody' : tempBody,
            'templateName' : tempName,
            
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.displayToastMessage("Success!","success","The template has been created successfully.");
            }else{
                this.displayToastMessage( "failed!","error","The template has not been created successfully.");
            }
            component.set("v.tbody","");
            component.set("v.tname","");
        });
        $A.enqueueAction(action);
        
    },
    displayToastMessage : function(titleOfMessage, typeOfMessage,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": titleOfMessage,
            "type" : typeOfMessage,
            "message": message
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
    }
})