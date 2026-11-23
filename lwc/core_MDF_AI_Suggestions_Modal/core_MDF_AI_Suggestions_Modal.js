// core_MDF_AI_Suggestions_Modal.js
import { LightningElement, api, track } from 'lwc';

export default class Core_MDF_AI_Suggestions_Modal extends LightningElement {

    // ── Public props set by the Aura parent ─────────────────────────────────
    @api isVisible  = false;
    @api isLoading  = false;

    // Raw SuggestionResult object passed in from Aura after the callout
    _suggestions = {};
    @api
    get suggestions() { return this._suggestions; }
    set suggestions(val) {
        this._suggestions = val || {};
        // Initialise every field's selection to "all checked"
        this._initSelections(this._suggestions);
    }

    @api errorMessage = '';

    // ── Tracked selection state ──────────────────────────────────────────────
    @track _selected = {
        focusArea       : null,
        priority        : [],
        country         : [],
        targetAudience  : [],
        ecosystemPartner: [],
        initiative      : [],
        brand           : [],
        technology      : [],
        outcomeMetric   : [],
        tactics         : []
    };

    // ── Derived getters ──────────────────────────────────────────────────────
    get hasError()   { return !!this.errorMessage; }
    get hasMatches() { return this._suggestions && this._suggestions.hasMatches; }

    get hasPriority()         { return this._suggestions.priority         && this._suggestions.priority.length         > 0; }
    get hasCountry()          { return this._suggestions.country          && this._suggestions.country.length          > 0; }
    get hasTargetAudience()   { return this._suggestions.targetAudience   && this._suggestions.targetAudience.length   > 0; }
    get hasEcosystemPartner() { return this._suggestions.ecosystemPartner && this._suggestions.ecosystemPartner.length > 0; }
    get hasInitiative()       { return this._suggestions.initiative       && this._suggestions.initiative.length       > 0; }
    get hasBrand()            { return this._suggestions.brand            && this._suggestions.brand.length            > 0; }
    get hasTechnology()       { return this._suggestions.technology       && this._suggestions.technology.length       > 0; }
    get hasOutcomeMetric()    { return this._suggestions.outcomeMetric    && this._suggestions.outcomeMetric.length    > 0; }
    get hasTactics()          { return this._suggestions.tactics          && this._suggestions.tactics.length          > 0; }

    get isFocusAreaChecked()  { return this._selected.focusArea === this._suggestions.focusArea; }

    // ── Init all checkboxes as checked ───────────────────────────────────────
    _initSelections(s) {
        if (!s) return;
        this._selected = {
            focusArea       : s.focusArea || null,
            priority        : s.priority         ? [...s.priority]         : [],
            country         : s.country          ? [...s.country]          : [],
            targetAudience  : s.targetAudience   ? [...s.targetAudience]   : [],
            ecosystemPartner: s.ecosystemPartner ? [...s.ecosystemPartner] : [],
            initiative      : s.initiative       ? [...s.initiative]       : [],
            brand           : s.brand            ? [...s.brand]            : [],
            technology      : s.technology       ? [...s.technology]       : [],
            outcomeMetric   : s.outcomeMetric    ? [...s.outcomeMetric]    : [],
            tactics         : s.tactics          ? [...s.tactics]          : []
        };
    }

    // ── Checkbox change handler ──────────────────────────────────────────────
    handleCheckboxChange(event) {
        const field   = event.target.dataset.field;
        const value   = event.target.dataset.value;
        const checked = event.target.checked;

        if (field === 'focusArea') {
            this._selected.focusArea = checked ? value : null;
            return;
        }

        const list = [...(this._selected[field] || [])];
        if (checked && !list.includes(value)) {
            list.push(value);
        } else if (!checked) {
            const idx = list.indexOf(value);
            if (idx > -1) list.splice(idx, 1);
        }
        // Reassign to trigger reactivity
        this._selected = { ...this._selected, [field]: list };
    }

    // ── Apply button ─────────────────────────────────────────────────────────
    handleApply() {
        this.dispatchEvent(new CustomEvent('applysuggestions', {
            detail: { ...this._selected },
            bubbles: true,
            composed: true
        }));
    }

    // ── Close / dismiss ──────────────────────────────────────────────────────
    handleClose() {
        this.dispatchEvent(new CustomEvent('closemodal', {
            bubbles: true,
            composed: true
        }));
    }

    handleBackdropClick(event) {
        // Only close if clicking the backdrop itself, not its children
        if (event.target === event.currentTarget) {
            this.handleClose();
        }
    }
}