({
	doInit : function(component, event, helper) {
		helper.getOptions(component,event);
	},
    
    handleClick : function(component, event, helper) {
        console.log("In Controller : handleClick");
        helper.updateCaseStatus(component,event);
    },
    
    handleChange : function(component, event, helper){
        console.log("In Controller : handleChange");
        helper.getDependentPicklist(component, event);
    },
})