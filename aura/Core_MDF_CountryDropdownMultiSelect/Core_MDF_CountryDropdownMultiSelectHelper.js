({
    syncOptions: function (component) {
        var availableOptions = component.get("v.availableOptions") || [];
        var selectedOptions = this.normalizeSelected(component.get("v.selectedOptions") || []);
        var selectedMap = {};
        var displayOptions = [];
        var selectedDisplayOptions = [];
        var showSelectedSection = component.get("v.showSelectedSection");

        for (var i = 0; i < selectedOptions.length; i++) {
            selectedMap[selectedOptions[i]] = true;
        }

        for (var j = 0; j < availableOptions.length; j++) {
            var sourceOption = availableOptions[j] || {};
            var value = sourceOption.value || sourceOption;
            var label = sourceOption.label || value;
            if (!value) {
                continue;
            }

            var displayOption = {
                label: label,
                value: value,
                selected: !!selectedMap[value]
            };

            if (displayOption.selected) {
                selectedDisplayOptions.push(displayOption);
            }

            if (!showSelectedSection || !displayOption.selected) {
                displayOptions.push(displayOption);
            }
        }

        component.set("v.selectedDisplayOptions", selectedDisplayOptions);
        component.set("v.displayOptions", displayOptions);
        this.updateSelectedCount(component, selectedOptions.length);
        this.applyFilter(component);
    },

    normalizeSelected: function (selectedOptions) {
        var normalized = [];
        for (var i = 0; i < selectedOptions.length; i++) {
            if (!selectedOptions[i]) {
                continue;
            }
            if (selectedOptions[i].indexOf && selectedOptions[i].indexOf(";") !== -1) {
                var splitValues = selectedOptions[i].split(";");
                for (var j = 0; j < splitValues.length; j++) {
                    if (splitValues[j]) {
                        normalized.push(splitValues[j]);
                    }
                }
            } else {
                normalized.push(selectedOptions[i]);
            }
        }
        return normalized;
    },

    applyFilter: function (component) {
        var searchTerm = (component.get("v.searchTerm") || "").toLowerCase();
        var displayOptions = component.get("v.displayOptions") || [];
        var filteredOptions = [];

        for (var i = 0; i < displayOptions.length; i++) {
            var option = displayOptions[i];
            var label = (option.label || "").toLowerCase();
            var value = (option.value || "").toLowerCase();
            if (!searchTerm || label.indexOf(searchTerm) !== -1 || value.indexOf(searchTerm) !== -1) {
                filteredOptions.push(option);
            }
        }

        component.set("v.filteredOptions", filteredOptions);
    },

    toggleSelection: function (component, value, isSelected) {
        var selectedOptions = this.normalizeSelected(component.get("v.selectedOptions") || []);
        var nextSelectedOptions = [];
        var found = false;

        for (var i = 0; i < selectedOptions.length; i++) {
            if (selectedOptions[i] === value) {
                found = true;
                if (isSelected) {
                    nextSelectedOptions.push(selectedOptions[i]);
                }
            } else {
                nextSelectedOptions.push(selectedOptions[i]);
            }
        }

        if (isSelected && !found) {
            nextSelectedOptions.push(value);
        }

        component.set("v.selectedOptions", nextSelectedOptions);
        component.set("v.hasError", false);
        component.set("v.errorMessage", "");
        this.updateSelectedCount(component, nextSelectedOptions.length);
        this.syncOptions(component);
    },

    updateSelectedCount: function (component, selectedCount) {
        component.set("v.selectedCount", selectedCount);
        component.set("v.selectedCountLabel", selectedCount === 1 ? "1 selected" : selectedCount + " selected");
    },

    validate: function (component) {
        var selectedOptions = this.normalizeSelected(component.get("v.selectedOptions") || []);
        var hasError = component.get("v.isRequired") && selectedOptions.length === 0;
        component.set("v.hasError", hasError);
        component.set("v.errorMessage", hasError ? component.get("v.requiredMessage") : "");
    }
})