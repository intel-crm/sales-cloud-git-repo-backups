/*!
 * Spectrum InlineAlert — informative variant
 * Extracted from @adobe/spectrum-css (Apache License 2.0)
 * https://github.com/adobe/spectrum-css/tree/main/components/inlinealert
 */

/* ── Token values resolved for light theme (medium scale) ── */
.spectrum-InLineAlert {
  /* Typography */
  --spectrum-inlinealert-heading-font-family: adobe-clean, "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --spectrum-inlinealert-heading-font-weight: 700;
  --spectrum-inlinealert-heading-font-style: normal;
  --spectrum-inlinealert-heading-font-size: 16px;
  --spectrum-inlinealert-heading-line-height: 1.2;

  --spectrum-inlinealert-content-font-family: adobe-clean, "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --spectrum-inlinealert-content-font-weight: 400;
  --spectrum-inlinealert-content-font-style: normal;
  --spectrum-inlinealert-content-font-size: 14px;
  --spectrum-inlinealert-content-line-height: 1.5;

  /* Size & Spacing */
  --spectrum-inlinealert-border-width: 2px;
  --spectrum-inlinealert-border-radius: 8px;
  --spectrum-inlinealert-icon-size: 18px;
  --spectrum-inlinealert-min-inline-size: 268px;
  --spectrum-inlinealert-header-min-block-size: 20px;
  --spectrum-inlinealert-spacing-edge-to-text: 16px;
  --spectrum-inlinealert-spacing-header-to-icon: 16px;
  --spectrum-inlinealert-spacing-header-content-button: 12px;

  /* Colors — neutral defaults */
  --spectrum-inlinealert-background-color: #ffffff;
  --spectrum-inlinealert-border-and-icon-color: rgb(110, 110, 110);
  --spectrum-inlinealert-header-color: rgb(19, 19, 19);
  --spectrum-inlinealert-content-color: rgb(41, 41, 41);

  /* Colors — semantic variants */
  --spectrum-inlinealert-border-and-icon-color-info: rgb(11, 120, 179);

  position: relative;
  display: inline-block;
  box-sizing: border-box;
  min-width: var(--spectrum-inlinealert-min-inline-size);
  width: 100%;

  padding-top: var(--spectrum-inlinealert-spacing-edge-to-text);
  padding-bottom: var(--spectrum-inlinealert-spacing-edge-to-text);
  padding-left: var(--spectrum-inlinealert-spacing-edge-to-text);
  padding-right: var(--spectrum-inlinealert-spacing-edge-to-text);

  border-width: var(--spectrum-inlinealert-border-width);
  border-style: solid;
  border-radius: var(--spectrum-inlinealert-border-radius);

  background-color: var(--spectrum-inlinealert-background-color);
  border-color: var(--spectrum-inlinealert-border-and-icon-color);
}

@media (forced-colors: active) {
  .spectrum-InLineAlert {
    background-color: Background;
    border-color: ButtonBorder;
  }
}

/* ── Icon ── */
.spectrum-InLineAlert-icon {
  width: var(--spectrum-inlinealert-icon-size);
  height: var(--spectrum-inlinealert-icon-size);
  flex-shrink: 0;
}

/* ── Header row (title + icon) ── */
.spectrum-InLineAlert-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--spectrum-inlinealert-spacing-header-to-icon);
  min-height: var(--spectrum-inlinealert-header-min-block-size);

  font-weight: var(--spectrum-inlinealert-heading-font-weight);
  font-family: var(--spectrum-inlinealert-heading-font-family);
  font-style: var(--spectrum-inlinealert-heading-font-style);
  font-size: var(--spectrum-inlinealert-heading-font-size);
  line-height: var(--spectrum-inlinealert-heading-line-height);
  text-transform: none;
  margin: 0;

  color: var(--spectrum-inlinealert-header-color);
}

/* ── Body text ── */
.spectrum-InLineAlert-content {
  display: block;
  margin-top: var(--spectrum-inlinealert-spacing-header-content-button);
  margin-bottom: 0;
  margin-left: 0;
  margin-right: 0;
  padding: 0;
  overflow-wrap: break-word;

  font-weight: var(--spectrum-inlinealert-content-font-weight);
  font-family: var(--spectrum-inlinealert-content-font-family);
  font-style: var(--spectrum-inlinealert-content-font-style);
  font-size: var(--spectrum-inlinealert-content-font-size);
  line-height: var(--spectrum-inlinealert-content-line-height);

  color: var(--spectrum-inlinealert-content-color);
}

.spectrum-InLineAlert-content ul {
  margin: 8px 0 0 0;
  padding-left: 20px;
}

.spectrum-InLineAlert-content li {
  margin-bottom: 4px;
}

/* ── Footer (CTA row) ── */
.spectrum-InLineAlert-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: var(--spectrum-inlinealert-spacing-header-content-button);
}

.spectrum-InLineAlert-footer:empty {
  display: none;
}

.spectrum-InLineAlert-footer-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ── Banner paragraph helpers ── */
.spectrum-InLineAlert-content-intro {
  margin: 0;
}

.spectrum-InLineAlert-content-subheading {
  margin: 8px 0 0 0;
}

/* ── Spectrum Button — base layout ── */
/* Extracted from @adobe/spectrum-css (Apache License 2.0)   */
/* https://github.com/adobe/spectrum-css/tree/main/components/button */
.spectrum-Button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  position: relative;
  vertical-align: top;
  -webkit-appearance: none;
  appearance: none;
  -webkit-user-select: none;
  user-select: none;

  height: 32px;
  min-width: 72px;
  padding: 0 14px;    /* pill-edge-to-text (16px) − border-width (2px) */
  border-width: 2px;
  border-style: solid;
  border-radius: 16px; /* pill: height / 2 */

  font-family: adobe-clean, "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: 14px;
  font-weight: 700;
  line-height: 1.2;
  text-decoration: none;
  white-space: nowrap;
  cursor: pointer;
  overflow: visible;

  transition: border 130ms linear, color 130ms linear, background-color 130ms linear;
  background: none;
}

.spectrum-Button::after {
  position: absolute;
  inset: 0;
  margin: -4px;        /* −(focus-gap 2px + border 2px) */
  border-radius: 18px; /* border-radius + focus-gap */
  content: "";
  pointer-events: none;
  transition: box-shadow 130ms ease-in-out;
}

.spectrum-Button:focus-visible {
  outline: none;
  box-shadow: none;
}

.spectrum-Button:focus-visible::after {
  box-shadow: 0 0 0 2px rgb(11, 120, 179);
}

.spectrum-Button-label {
  display: block;
  line-height: 1.2;
  text-align: center;
}

/* ── Button: secondary variant (fill, light theme) ── */
/* gray-100 = rgb(233,233,233)  gray-200 = rgb(219,219,219) */
.spectrum-Button--secondary {
  background-color: rgb(233, 233, 233);
  border-color: transparent;
  color: rgb(41, 41, 41);  /* neutral-content-color-default = gray-800 */
}

.spectrum-Button--secondary:hover {
  background-color: rgb(219, 219, 219);
  color: rgb(19, 19, 19);  /* gray-900 */
  text-decoration: none;
}

.spectrum-Button--secondary:active {
  background-color: rgb(219, 219, 219);
}

@media (forced-colors: active) {
  .spectrum-Button {
    border-color: ButtonBorder;
    background-color: ButtonFace;
    color: ButtonText;
  }
}

/* ── Enroll CTA — accent blue (overrides Button base colors) ── */
#sales-qualifier-enroll-cta {
  background-color: rgb(11, 120, 179);
  border-color: transparent;
  color: #ffffff;
}

#sales-qualifier-enroll-cta:hover {
  background-color: rgb(9, 101, 153);
  color: #ffffff;
  text-decoration: none;
}

/* ── Spectrum Checkbox ── */
/* Extracted from @adobe/spectrum-css (Apache License 2.0)       */
/* https://github.com/adobe/spectrum-css/tree/main/components/checkbox */
.spectrum-Checkbox {
  display: inline-flex;
  align-items: flex-start;
  position: relative;
  min-height: 32px;   /* component-height-100 */
  max-width: 100%;
  vertical-align: top;
  cursor: pointer;
  color: rgb(41, 41, 41);
  font-family: adobe-clean, "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: 14px;
}

.spectrum-Checkbox:hover .spectrum-Checkbox-box::before {
  border-color: rgb(19, 19, 19);
}

/* Real input — visually hidden, full-area hit target */
.spectrum-Checkbox-input {
  position: absolute;
  width: 100%;
  height: 100%;
  opacity: 0;
  z-index: 1;
  cursor: pointer;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.spectrum-Checkbox-input:disabled {
  cursor: default;
}

/* Visual checkbox box */
.spectrum-Checkbox-box {
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  box-sizing: border-box;
  width: 14px;   /* checkbox-control-size-medium */
  height: 14px;
  margin: 9px 0; /* (32px component-height − 14px control) / 2 */
  flex-shrink: 0;
  flex-grow: 0;
}

/* The visible square drawn via ::before */
.spectrum-Checkbox-box::before {
  content: "";
  display: block;
  position: absolute;
  box-sizing: border-box;
  width: 14px;
  height: 14px;
  border-radius: 3px;
  border-width: 2px;
  border-style: solid;
  border-color: rgb(110, 110, 110); /* neutral control color */
  background-color: transparent;
  transition: border 130ms ease-in-out;
}

/* Focus ring via ::after */
.spectrum-Checkbox-box::after {
  content: "";
  display: block;
  position: absolute;
  inset: 0;
  border-radius: 5px; /* control-corner-radius + focus-gap */
  transition: box-shadow 130ms ease-out;
}

.spectrum-Checkbox-input:focus-visible + .spectrum-Checkbox-box::after {
  box-shadow: 0 0 0 2px rgb(11, 120, 179);
  margin: -2px;
}

/* Checkmark SVG */
.spectrum-Checkbox-checkmark {
  width: 10px;
  height: 10px;
  position: relative;
  z-index: 1;
  color: #ffffff;
  fill: currentColor;
  opacity: 0;
  transform: scale(0);
  transition: opacity 130ms ease-in-out, transform 130ms ease-in-out;
}

/* Checked state: thick border fills the box, white canvas shows checkmark */
.spectrum-Checkbox-input:checked + .spectrum-Checkbox-box::before {
  border-width: 7px; /* selected-border-width = control-size / 2 */
  border-color: rgb(19, 19, 19);
  background-color: #ffffff;
}

.spectrum-Checkbox-input:checked + .spectrum-Checkbox-box .spectrum-Checkbox-checkmark {
  opacity: 1;
  transform: scale(1);
}

.spectrum-Checkbox-label {
  display: block;
  margin-left: 8px;  /* text-to-control-100 */
  margin-top: 9px;   /* aligns baseline with box center */
  font-size: 14px;
  line-height: 1.3;
  color: rgb(41, 41, 41);
}

@media (forced-colors: active) {
  .spectrum-Checkbox-box::before {
    border-color: ButtonText;
    background-color: Canvas;
  }

  .spectrum-Checkbox-input:checked + .spectrum-Checkbox-box::before {
    border-color: Highlight;
  }

  .spectrum-Checkbox-checkmark {
    color: CanvasText;
  }

  .spectrum-Checkbox-label {
    color: CanvasText;
  }
}

/* ── Informative variant ── */
.spectrum-InLineAlert--info {
  border-color: var(--spectrum-inlinealert-border-and-icon-color-info);
}

.spectrum-InLineAlert--info .spectrum-InLineAlert-icon {
  color: var(--spectrum-inlinealert-border-and-icon-color-info);
  fill: var(--spectrum-inlinealert-border-and-icon-color-info);
}

@media (forced-colors: active) {
  .spectrum-InLineAlert--info {
    border-color: ButtonBorder;
  }
}
