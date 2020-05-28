({
	doInit : function(component, event, helper) {
        helper.getCaseFieldList(component, event);
    },
    
    handleSave : function(component, event, helper) {
        helper.saveAction(component, event);
    },
    
    handleObjectChange : function(component, event, helper) {
    	helper.objectChange(component, event);
    },
    
    handleLayoutChange : function(component, event, helper) {
    	helper.layoutChange(component, event);
    },
    
    //To close the quick action pop-up
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        if(component.get("v.editMode") == true) {
            helper.createEventToClose(component, event);
        }
    },
})