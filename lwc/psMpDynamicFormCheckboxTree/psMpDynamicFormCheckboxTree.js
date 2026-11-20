import { LightningElement, track, api } from "lwc";
import selectAll from '@salesforce/label/c.Core_PMP_Select_All';
import deslectAll from '@salesforce/label/c.Core_PMP_Deselect_All';
import expandTitle from '@salesforce/label/c.PMP_Expand';
import expandAlternative from '@salesforce/label/c.PMP_Expand_Category';
import collapseTitle from '@salesforce/label/c.PMP_Collapse';
import collapseAlternative from '@salesforce/label/c.PMP_Collapse_Category';


export default class PsMpDynamicFormCheckboxTree extends LightningElement {
    // input vars
    @api label = "Missing label!";
    @track _options = null;
    @api interactionType = "recursiveselect";
    @api accordionType = "collapsible";
    @api valueType;
    @api type = "filter";

    @track checkboxes = [];
    initialCheckboxes = [];
    _debounceSearchTimer;
    @track _searching = false;
    @track _scrollToResult = false;

    @api collapsible = false;
    @track clearFilters = false;

    @track expandedSections = {}; // used to toggle open/close sections
    @api updateFormCallback = null;
    @api theme = "";
    @track searchString = "";

    // Child Tree Attributes
    @api checkbox;
    @api topLevel = false;
    @api disabled = false;
    @track isExpanded = false;
    @api highlight = false;
    labelSelectAll = selectAll;
    labelDeslectAll = deslectAll;
    _expandedChildSections = {};
    @api isChild = false;
    @track _hasBeenRendered = false;


    connectedCallback() {
        if (this.options != null) {
            this._setInitialValue();
        }
    }

    update() {
        this.dispatchEvent(
            new CustomEvent("update", {
                detail: { valid: this.valid, value: this.value, touched: this.touched }
            })
        );

        if (typeof this.updateFormCallback === "function") {
            this.updateFormCallback(this);
        }
    }

    @api set options(val) {
        // do pre processing
        this._options = val;
        this._setInitialValue();
    }
    get options() {
        return this._options || [];
    }

    get boxes() {
        return this.checkboxes.map((box, idx) => ({ idx, value: box }));
    }

    debounce(callback, wait) {
        let timeout;
        return (...args) => {
            const context = this;
            clearTimeout(timeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            timeout = window.setTimeout(() => callback.apply(context, args), wait);
        };
    }

    handleSearchChange = this.debounce(() => {
        this.searchString = this.template.querySelector("lightning-input").value;
        this.search();
    }, 200);

    handleSearchKeydown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            event.stopPropagation();
            if (this._searching) {
                this._scrollToResult = true;
            } else {
                this.scrollToFirstResult();
            }
        }
    }

    get classes() {
        return {
            parentHost: "slds-p-around_medium " + (this.required ? "isRequired " : "isNotRequired ") + (" theme-" + this.theme) + (" type-" + this.type),
            childHost: 'child childCheckbox clearFilters ' + (this.topLevel ? 'topLevel ' : '') + (this.collapsible ? 'collapsible ' : '') + 'theme-' + this.theme + ' type-' + this.type,
            toggleClass: 'slds-m-right_xx-small cursor slds-icon_container ' + (this.isExpanded ? 'slds-icon-utility-dash' : 'slds-icon-utility-add'),
            toggleIcon: 'utility:' + (this.isExpanded ? 'dash' : 'add'),
            toggleAlternativeText: this.isExpanded ? collapseAlternative : expandAlternative,
            toggleTitle: this.isExpanded ? collapseTitle : expandTitle,
            checkboxContainerClass: 'checkboxPadding slds-m-vertical_xx-small ' + (this.highlight ? 'highlight slds-p-vertical_xx-small ' : '') + (this.firstResult ? 'firstResult ' : '') + (this.prerelease ? 'prerelease ' : ''),
            checkboxInputClass: (this.collapsible ? 'collapsible-input ' : '') + (this.firstResult ? 'firstResult ' : ''),
            childrenVisible: this.isExpanded ? 'child-visible': 'child-hidden'
        };
    }



    get ifs() {
        return this.isChild ? {
            toggleCollapse: this.collapsible && this.children && this.children.length > 0,
            childVisible: this.isExpanded,
            hasChildren: this.children && this.children.length > 0,
            isPrerelease: this.checkbox && this.checkbox.prerelease,
            showTotalSelected: (this.topLevel === true || this.topLevel === 'true') && (this.checkbox && this.checkbox.totalSelected > 0),
            isTopLevel: (this.topLevel === true || this.topLevel === 'true')
        } : {
            hasLabel: this.label ? true : false,
            showErrorMessage: this.touched && !this.valid,
        }
    }

    _updateForm() {
        this.update();
    }

    handleChildEvent(event) {
        if (this.isChild){
            this.dispatchEvent(
                new CustomEvent("childevent", {
                  detail: event.detail
                })
              );
        } else {
            let detail = event.detail;
            event.preventDefault();
            switch (detail.type) {
                case "selectallfilter":
                    this._toggleChildren(detail.value, true);
                    break;
                case "togglesection":
                    this._toggleSection(detail);
                    break;
                case "clearallfilter":
                    this._toggleChildren(detail.value, false);
                    break;
                case "checkboxchange":
                    this._setValue(detail.value, detail.checked);
                    break;
                default:
                    break;
            }
        }
    }

    _toggleSection(detail) {
        let checkboxValue = detail.value;
        let newExpandedSection = { ...this.expandedSections };
        if (newExpandedSection[checkboxValue]) {
            newExpandedSection[checkboxValue] = false;
        } else {
            newExpandedSection[checkboxValue] = true;
        }
        this.expandedSections = newExpandedSection;
    }

    _setInitialValue() {
        let checkboxes = this.options.slice(),
            listOfChecked = [],
            complexValue = [];

        let listOfExpandedParent = {};

        const recurseCheckboxTree = (boxes) => {
            let anyChecked = false;
            let returnBoxes = (boxes || []).map((box) => {
                let checkbox = { ...box };
                let complexVal;
                let isChecked = checkbox.checked;
                if (checkbox.subType === "text") {
                    isChecked = (checkbox.textValue || "").length > 0;
                }
                if (checkbox.subType === "radio") {
                    isChecked = checkbox.radioOptions.find(opt => opt.isSelected);
                }
                checkbox.checked = isChecked;
                if (isChecked) {
                    anyChecked = true;
                    listOfChecked.push(checkbox.value);
                    complexVal = { id: checkbox.value, ...checkbox.additionalValues };
                    // adds text input value
                    if (checkbox.subType === "text") complexVal.value = checkbox.textValue;
                    // adds radio input value
                    if (checkbox.subType === "radio") complexVal.value = checkbox.radioOptions.find(opt => opt.isSelected).value;
                    complexValue.push(complexVal);
                }

                let returnVal = recurseCheckboxTree(checkbox.children);
                let isAnyChildChecked = returnVal.descendantChecked;

                checkbox = {
                    ...checkbox,
                    hasChildren: checkbox.children.length > 0,
                    children: returnVal.checkboxes,
                    open: false,
                    delayRender: false,
                    totalSelected: 0,
                    highlight: false,
                    firstResult: false
                };

                if (isAnyChildChecked) {
                    listOfExpandedParent[checkbox.value] = true;
                }

                return checkbox;
            });

            return {
                checkboxes: returnBoxes,
                descendantChecked: anyChecked
            };
        };
        let updatedCheckboxes = recurseCheckboxTree(checkboxes).checkboxes;
        this.checkboxes = this._updateTotalValues(updatedCheckboxes);
        this.expandedSections = { ...this.expandedSections, ...listOfExpandedParent };
        // console.log('setInitial Value ', JSON.parse(JSON.stringify(this.checkboxes)));
        this._setInputValue(listOfChecked, complexValue);
    }

    _setValue(value, checkboxValue) {
        let allChecked = [],
            complexValue = [],
            recursive = this.interactionType === "recursive",
            parent = this.interactionType === "parent",
            recursiveSelect = this.interactionType === "recursiveselect";

        let listOfExpandedParent = {};
        let newRecursedValue;

        const recurseCheckboxTree = (boxes, recursedValue) => {
            boxes = boxes.map((checkbox) => {
                let complexVal;
                // Need to assign default variable checked otherwise any asignment to undefined will break code below
                // checkbox = Object.assign({checked: false}, checkbox);
                checkbox = { checked: false, ...checkbox };

                newRecursedValue = undefined;
                // console.log('recurseCheckboxTree',idx,checkbox, checkbox.value, recursedValue, value);

                if (checkbox.value === value) {
                    // text input logic
                    if (checkbox.subType === "text") {
                        checkbox.textValue = checkboxValue; // sets text value
                        checkboxValue = checkboxValue.length > 0; // "checked" if text value exists
                    } else if (checkbox.subType === "radio") {
                        checkboxValue = checkboxValue ? true : false; // "checked" if value exists
                    }

                    checkbox.checked = checkboxValue;

                    // recursive - set children to parents value recursively
                    if (recursive) newRecursedValue = checkboxValue;
                    // parent - uncheck children if parent is unchecked
                    if (parent && !checkboxValue) newRecursedValue = false;
                    // recursiveselect - set children if selected
                    if (recursiveSelect && checkboxValue) newRecursedValue = true;
                } else if (recursedValue != null) {
                    // null or undefined
                    checkbox.checked = recursedValue;
                    // clears out text input if parent is unchecked
                    if (checkbox.subType === "text" && !recursedValue) checkbox.textValue = "";
                    // clears out radio if parent is unchecked
                    if (checkbox.subType === "radio" && !recursedValue) {
                        checkbox.radioOptions.forEach(opt => {
                            opt.isSelected = false;
                        });
                    }
                    if (recursive || parent || recursiveSelect) newRecursedValue = recursedValue;
                }

                if (checkbox.children && checkbox.children.length) {
                    let tempChildren = recurseCheckboxTree(checkbox.children, newRecursedValue);
                    checkbox = { ...checkbox, children: tempChildren };
                    // recursive - after recursing tree -- uncheck parents of any unchecked
                    if (recursive) {
                        if (checkbox.children.find(c => !c.checked)) {
                            checkbox.checked = false;
                        } else {
                            checkbox.checked = true;
                        }
                    }
                    // parent - after recursing tree -- check parents of any checked
                    if (parent) {
                        // if any children are checked, check parent
                        if (checkbox.children.find(c => c.checked)) {
                            checkbox.checked = true;
                        }
                    }
                    if (this.collapsible) {
                        if (newRecursedValue) {
                            listOfExpandedParent[checkbox.value] = true;
                        }
                    }
                }

                if (checkbox.checked) {
                    allChecked.push(checkbox.value);
                    complexVal = { id: checkbox.value, ...checkbox.additionalValues };

                    // adds text input value
                    if (checkbox.subType === "text") complexVal.value = checkbox.textValue;
                    // adds radio input value
                    if (checkbox.subType === "radio") complexVal.value = checkbox.radioOptions.find(opt => opt.isSelected).value;
                    complexValue.push(complexVal);
                }
                return checkbox;
            });
            return boxes;
        };

        let updatedCheckboxes = recurseCheckboxTree(this.checkboxes.slice(), null);
        this.checkboxes = this._updateTotalValues(updatedCheckboxes);
        this.expandedSections = { ...this.expandedSections, ...listOfExpandedParent };
        this._setInputValue(allChecked, complexValue);
    }

    printJSON(json) {
        return JSON.parse(JSON.stringify(json));
    }

    _updateTotalValues(array) {
        const recurseDescendantCheckedCount = function(boxes) {
            let totalDescendantCount = 0;

            boxes.forEach(function(checkbox) {
                let _currentDescendant = 0;

                if (checkbox.children && checkbox.children.length) {
                    _currentDescendant = recurseDescendantCheckedCount(checkbox.children);
                }
                if (checkbox.checked) {
                    _currentDescendant++;
                }
                checkbox.totalSelected = _currentDescendant;
                totalDescendantCount += _currentDescendant;
            });
            return totalDescendantCount;
        };

        recurseDescendantCheckedCount(array);

        return array;
    }

    _setInputValue(listOfChecked, complexValue) {
        let value,
            oldValue = this.value;
        if (this.valueType === "picklist") {
            value = listOfChecked.join(";");
        } else if (this.valueType === "complex") {
            value = complexValue;
        } else {
            value = listOfChecked;
        }
        if (oldValue || listOfChecked.length) this.value = value;
        this.valid = this._isValid();
        this._updateForm();
    }

    _isValid() {
        let retVal = true;
        if (this.required) {
            if (!this.value || !this.value.length) {
                retVal = false;
            }
        }
        return retVal;
    }

    search() {
        let minimumChars = 2;
        let checkboxes = this.checkboxes.slice();
        let q = this.searchString.toLowerCase() || false;
        let listOfExpandedParent = {};
        let foundFirstResult = false;

        if (q && q.length >= minimumChars) {
            q = q.replace(/[-[\]{}()*+?.,\\^$|#]/g, "\\$&");
            q = q.replace(/\s+/g, "(\\s*?)"); // make white space variable size if it exists
        }
        const recurseSearchAndOpenParent = chckbxs => {
            let openParent = false;

            chckbxs.forEach(child => {
                child.firstResult = false;
                if (q && q.length >= minimumChars) {
                    child.highlight = child.label.toLowerCase().match(q) ? true : false;
                    if (child.subType === "radio") {
                        child.radioOptions.forEach(radio => {
                            radio.highlight = radio.label.toLowerCase().match(q) ? true : false;
                            if (radio.highlight) child.highlight = true;
                        });
                    }
                } else {
                    child.highlight = false;
                    if (child.subType === "radio") {
                        child.radioOptions.forEach(radio => {
                            radio.highlight = false;
                        });
                    }
                }
                if (child.highlight) {
                    openParent = true;
                    if (!foundFirstResult) {
                        child.firstResult = true;
                        foundFirstResult = true;
                    }
                }
                if (!q && child.checked) openParent = true;
                if (child.children && child.children.length) {
                    if (recurseSearchAndOpenParent(child.children)) {
                        openParent = true;
                        if (this.collapsible) {
                            listOfExpandedParent[child.value] = true;
                        }
                    }
                }
            });
            return openParent;
        };
        checkboxes.forEach(checkbox => {
            checkbox.firstResult = false;
            if (q && q.length >= minimumChars) {
                checkbox.highlight = checkbox.label.toLowerCase().match(q) ? true : false;
            } else {
                checkbox.highlight = false;
            }
            if (!foundFirstResult && checkbox.highlight) {
                checkbox.firstResult = true;
                foundFirstResult = true;
            }

            checkbox.open = recurseSearchAndOpenParent(checkbox.children);
            if (checkbox.open) {
                listOfExpandedParent[checkbox.value] = true;
            }
        });
        this.checkboxes = checkboxes;
        this.expandedSections = listOfExpandedParent;

        // if (!q) helper.setInitialValue(component, helper);
        this._searching = false;
        if (this._scrollToResult) {
            this._scrollToFirstResult();
        }
        this._scrollToResult = false;
    }

    scrollToFirstResult() {
        let childNodes = this.template.querySelectorAll('c-ps-mp-dynamic-form-checkbox-tree');
        childNodes.forEach((elem) => elem.childScrollToFirstResult());
    }

    _toggleChildren(value, checkboxValue) {
        let allChecked = [],
            complexValue = [],
            complexVal;

        let listOfExpandedParent = {};

        const recurseCheckboxTree = (boxes, recursedValue) => {
            boxes = boxes.map((checkbox) => {
                let newRecursedValue;
                checkbox = { checked: false, ...checkbox };
                if (checkbox.value === value) {
                    // text input logic
                    newRecursedValue = checkboxValue;
                    // Toggles parent
                    // checkbox.checked = checkboxValue;
                    checkbox.open = true;
                } else if (recursedValue != null) {
                    // null or undefined
                    checkbox.checked = recursedValue;
                    // clears out text input if parent is unchecked
                    if (checkbox.subType === "text" && !recursedValue) checkbox.textValue = "";
                    // clears out radio if parent is unchecked
                    if (checkbox.subType === "radio" && !recursedValue) {
                        checkbox.radioOptions.forEach(function(opt) {
                            opt.isSelected = false;
                        });
                    }
                    newRecursedValue = recursedValue;
                }
                if (checkbox.children && checkbox.children.length) {
                    let tempChildren = recurseCheckboxTree(checkbox.children, newRecursedValue);
                    checkbox = { ...checkbox, children: tempChildren };

                    if (this.collapsible) {
                        if (newRecursedValue) {
                            listOfExpandedParent[checkbox.value] = true;
                        }
                    }
                }

                if (checkbox.checked) {
                    allChecked.push(checkbox.value);
                    complexVal = { id: checkbox.value, ...checkbox.additionalValues };
                    // adds text input value
                    if (checkbox.subType === "text") complexVal.value = checkbox.textValue;
                    // adds radio input value
                    if (checkbox.subType === "radio") complexVal.value = checkbox.radioOptions.find(opt => opt.isSelected).value;
                    complexValue.push(complexVal);
                }
                return checkbox;
            });
            return boxes;
        };

        let updatedCheckboxes = recurseCheckboxTree(this.checkboxes.slice(), null);
        this.checkboxes = this._updateTotalValues(updatedCheckboxes);
        this.expandedSections = { ...this.expandedSections, ...listOfExpandedParent };
        this._setInputValue(allChecked, complexValue);
    }

    /* Child Functions */
    handleAction(e) {
        let type = e.currentTarget.dataset.type;
        let dispatchObject = null;

        console.log('handleAction', type);


        switch (type) {
          case "selectallfilter":
          case "togglesection":
          case "clearallfilter":
              dispatchObject = {
                detail: {
                  type: type,
                  checkbox: this.checkbox,
                  value: this.checkbox.value
                }
              };
              break;
          case "checkboxchange":
            dispatchObject =  {
              detail: {
                type: type,
                checkbox: this.checkbox,
                value: this.checkbox.value,
                checked: e.currentTarget.checked
              }
            }
            break;
          default:
            break;
        }

        if (dispatchObject != null) {
          this.dispatchEvent(new CustomEvent("childevent", dispatchObject));
        }
      }

    @api set expandedChildSections(val){
        this._expandedChildSections = val;
        this.isExpanded = (this._expandedChildSections[this.checkbox.value]);
        if (this.isExpanded){
            // if this has been expanded once this will be in hasBeenRendered state
            this._hasBeenRendered = true;
        }
    }

    get expandedChildSections() {
    return this._expandedChildSections || {};
    }

    @api childScrollToFirstResult() {
        let childNodes;
        if (this.firstResult) {
            this.template.querySelector('input').focus();
        } else if (this.children.length > 0){
            childNodes = this.template.querySelectorAll('c-ps-mp-dynamic-form-checkbox-tree');
            childNodes.forEach((elem) => { elem.childScrollToFirstResult()});
        }
    }


    get prerelease() {
    return this.checkbox ? this.checkbox.prerelease : false;
    }
    get firstResult() {
    return this.checkbox ? this.checkbox.firstResult : false;
    }

    get children() {
    return this.checkbox.children || [];
    }



}