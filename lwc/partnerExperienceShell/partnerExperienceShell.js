import { LightningElement } from "lwc";
import basePath from "@salesforce/community/basePath";
import intelLogo from "@salesforce/resourceUrl/partnerIntelLogo";

const MENU_ITEMS = [
  { id: "home", label: "Home", icon: "utility:home" },
  { id: "benefits", label: "Manage Benefits", icon: "utility:setup" },
  { id: "points", label: "Points & Rewards", icon: "utility:database" },
  { id: "warranty", label: "Warranty", icon: "utility:shield" },
  { id: "training", label: "Sales & Training", icon: "utility:knowledge_base" },
  { id: "opportunities", label: "Opportunities", icon: "utility:chart" },
  { id: "resources", label: "Resources & Tools", icon: "utility:open_folder" },
  { id: "account", label: "Account Management", icon: "utility:user" },
  { id: "reports", label: "Reports & Analytics", icon: "utility:chart" }
];

/**
 * @slot default Main content of the existing Experience Cloud page.
 */
export default class PartnerExperienceShell extends LightningElement {
  logoUrl = intelLogo;
  searchTerm = "";
  menuOpen = false;

  get homeUrl() {
    return `${basePath.replace(/\/$/, "")}/`;
  }

  get menuItems() {
    const query = this.searchTerm.trim().toLocaleLowerCase();
    return MENU_ITEMS.filter((item) =>
      item.label.toLocaleLowerCase().includes(query)
    ).map((item) => ({
      ...item,
      isHome: item.id === "home"
    }));
  }

  get noMatches() {
    return this.menuItems.length === 0;
  }

  get filterStatus() {
    return this.searchTerm.trim()
      ? `${this.menuItems.length} matching navigation items.`
      : "";
  }

  get shellClass() {
    return this.menuOpen ? "partner-shell menu-open" : "partner-shell";
  }

  get menuToggleLabel() {
    return this.menuOpen ? "Close navigation" : "Open navigation";
  }

  handleSearch(event) {
    this.searchTerm = event.target.value;
    this.menuOpen = Boolean(this.searchTerm.trim());
  }

  toggleMenu() {
    this.menuOpen = !this.menuOpen;
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.menuOpen = false;
      this.template.querySelector(".menu-toggle").focus();
    }
  }

  handleSkipToContent(event) {
    event.preventDefault();
    this.template.querySelector("main").focus();
  }
}