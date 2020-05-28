({
    init : function(component, event, helper) {
        helper.getColumnAndAction(component, event);
        helper.getActions(component, event);
        
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'delete':
                helper.deleteRecord(component, event);
                break;
        }
    },
    
    
    closeModel: function(component, event, helper) {
        component.set("v.editRecord", false);
        component.set("v.deleteRecord", false);
        helper.refreshDataTable(component, event);
    },
    
    handleRefresh : function(component, event, helper) {
        helper.refreshDataTable(component, event);
    },
})