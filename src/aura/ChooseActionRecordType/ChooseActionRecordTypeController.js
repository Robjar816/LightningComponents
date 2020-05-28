({
	handleNext : function(component, event, helper) {
		helper.nextNavigation(component, event);
	},
    
    handleChange : function(component, event, helper) {
    	helper.newRadioButtonSelected(component, event);        
    },
    
    //To close the quick action popup
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})