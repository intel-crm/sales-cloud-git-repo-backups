({

	getApiName : function(inputType) {

		// this map is a list of the available form input types and their component api names
    var apiMap = {

      text:           "c:MarketplaceFormInputText",
      dropdown:       "c:MarketplaceFormDropdown",
      richtext:       "c:MarketplaceFormRichTextEditor", //ISGFormRichTextEditor
      textarea:       "c:MarketplaceFormTextArea",
      uploader:       "c:MarketplaceFormImageUploader",
      checkbox:       "c:MarketplaceFormCheckbox",
      resources:      "c:MarketplaceFormResources",
      radio:					"c:MarketplaceFormRadio",
      dropdownradio:  "c:MarketplaceFormDropdownRadioCombo",

    };

    if (!apiMap[inputType]) {
			throw('No component built for type of input: ' + inputType);
		}
    return apiMap[inputType];
	}

})