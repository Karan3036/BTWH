({
	getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},
	getFields: function (component, event, helper) {
        debugger;
		var action = component.get("c.getFieldSet");
		action.setParams({
			objectName: 'buildertek__BT_Payment__c',
			fieldSetName: 'buildertek__Payment_FieldSet'
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
				component.set("v.listOfFields", listOfFields);
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	}
})