({
	doInit : function(component, event, helper) {
		helper.getOptions(component,event);
	},
    
    handleUpdate : function(component, event, helper) {
        console.log("In Controller : handleUpdate");
        helper.updateCaseStatus(component,event);
    },
    
    handleChange : function(component, event, helper){
        console.log("In Controller : handleChange");
        helper.getDependentPicklist(component, event);
    },
})