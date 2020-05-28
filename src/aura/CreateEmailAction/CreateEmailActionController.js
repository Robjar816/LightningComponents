({
    doInit : function(component, event, helper) {
        helper.getDataForUI(component, event);
    },
    
	handleSave : function(component, event, helper) {
        helper.saveAction(component, event);
    },
    
    //To close the quick action pop-up
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        if(component.get("v.editMode") == true) {
            helper.createEventToClose(component, event);
        }
    },
})