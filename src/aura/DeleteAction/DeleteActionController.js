({
    handleDelete : function(component, event, helper) {
		helper.deleteAction(component, event);
	},
    handleClose : function(component, event, helper) {
        helper.createEventToClose(component, event);
    },
})