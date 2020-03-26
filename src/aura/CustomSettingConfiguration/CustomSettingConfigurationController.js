({   
    init: function (component, event, helper) {
        helper.getColumnAndAction(component);
        helper.getTemplates(component, helper);
        
    },createTemplate: function (component, event, helper) {
        component.set("v.showCreateLayout",true);
        component.set("v.showViewLayout",false);
        component.set("v.showEditLayout",false);
        component.set("v.showNewLayout",true);
        component.set("v.tname","");
        component.set("v.tbody","");
        
    }, handleEdit: function (component, event, helper) {
        helper.editRecord(component, event);
        
    }, handleEditSave: function (component, event, helper){
        helper.updateTemplates(component, event);
        
    }, handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'delete':
                helper.deleteRecord(component, event);
                break;
            case 'view':
                helper.viewRecord(component, event);
                break;
        }
    }, closeModel: function(component, event, helper) {
        component.set("v.showCreateLayout", false);
        
    }, handleSave: function(component, event, helper) {
        helper.saveTemplates(component, event);
        
    }
})