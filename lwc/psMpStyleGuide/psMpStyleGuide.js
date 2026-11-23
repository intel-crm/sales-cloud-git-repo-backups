import { LightningElement, api, track } from 'lwc';

import { subscribe } from 'c/ipaRedux';
import summary from './summary.html';
import colors from './colors.html';
import buttonsAndLinks from './buttonsandlinks.html';
import typographyAndHeadings from './typographyandheadings.html';
import layout from './layout.html';
import icons from './icons.html';
import devguide from './devguide.html';

import resource from '@salesforce/resourceUrl/IpaResources';



export default class Styleguide extends LightningElement {

    @api page;
    @track breakpoint;

    connectedCallback() {
        this._subscription = subscribe('ui.breakpoint', breakpoint => {
            this.breakpoint = breakpoint;
        });
    }

    renderedCallback() {
        if (this.page === 'Icons') this.setupIcons();
    }

    disconnectedCallback() {
        this._subscription();
    }

    render() {
        switch (this.page) {
            case 'Colors':
                return colors;
            case 'Buttons and Links':
                return buttonsAndLinks;
            case 'Typography and Headings':
                return typographyAndHeadings;
            case 'Layout':
                return layout;
            case 'Icons':
                return icons;
            case 'Dev Guide':
                return devguide;
            default:
                return summary;
        }
    }

    get breakpointImages() {
        return {
            mobile: resource + '/images/style-guide-breakpoints/breakpoint-mobile.png',
            tablet: resource + '/images/style-guide-breakpoints/breakpoint-tablet.png',
            desktop: resource + '/images/style-guide-breakpoints/breakpoint-large-desktop.png'
        };
    }

    get layoutGridIteration() {
        return {
            s12: (new Array(12)).fill(0).map(Math.random),
            s6: (new Array(6)).fill(0).map(Math.random),
            s4: (new Array(4)).fill(0).map(Math.random),
            s3: (new Array(3)).fill(0).map(Math.random),
            s2: (new Array(2)).fill(0).map(Math.random),
        };
    }

    get buttonMenuItems() {
        return [
            { label: 'Lorem Ipsum Home', externalUrl: 'http://www.intel.com' },
            { label: 'Lorem Ipsum About', communityPage: 'Home' }
        ];
    }

    setupIcons() {
        const allIcons = [];
        const createSVG = (charsvg, ex, em) => {
            let svgEl = document.createElementNS("http://www.w3.org/2000/svg", "svg");
            let pathEl = document.createElementNS("http://www.w3.org/2000/svg", "path");
            pathEl.setAttribute('d', charsvg);
            pathEl.setAttribute('transform', 'translate(128,' + em + ') scale(1, -1)')
            pathEl.style.fill = 'currentColor';
            svgEl.setAttribute('viewBox', '0 0 ' + (ex*1+256) + ' ' + (em*1+256)); //FIXME
            svgEl.appendChild(pathEl);
            return svgEl;
        };

        let target = this.template.querySelector('.icons-container');
        let intelFontUrl = 'https://www.intel.com/etc/designs/intel/clientlibs/pages/site-global-icons/font/site-global-icons.svg';
        fetch(intelFontUrl).then(resp => resp.text())
        .then(font => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(font, "text/xml");
            let glyphs = xmlDoc.getElementsByTagName('glyph');
            let fontFamily = xmlDoc.getElementsByTagName('font-face')[0].getAttribute('font-family') || xmlDoc.getElementsByTagName('font')[0].id;
            let h5 = document.createElement("h5");
            h5.innerText = 'Intel Font';
            target.appendChild(h5);
            let description = document.createElement("p");
            description.classList.add("slds-p-top_large");
            description.classList.add("color-pink");
            description.innerText = 'This list of icons comes from the Intel shared header component.';
            target.appendChild(description);
            let ff = xmlDoc.getElementsByTagName('font-face')[0];
            let em = ff.getAttribute('units-per-em');
            let pre = document.createElement("pre");
            pre.innerText = "1em = " + em + "\nfont-family: \"" + fontFamily + "\"\nfont-weight: " + ff.getAttribute('font-weight') + "\n";
            target.appendChild(pre);
            let example = document.createElement("p");
            example.classList.add("example");
            example.classList.add("color-pink");
            example.innerText = '<span class="intel-icon fa-NAME"></span>';
            target.appendChild(example);

            glyphs.forEach(glyph => {
                if (glyph) {
                    let char = glyph.getAttribute('unicode');
                    let unicode = char ? (char.charCodeAt(0).toString(16)) : null;
                    let charname = glyph.getAttribute('glyph-name');
                    let charsvg = glyph.getAttribute('d');
                    let ex = glyph.getAttribute('horiz-adv-x') || em;
                    let codeDiv = document.createElement('div');
                    codeDiv.classList.add('char-code');
                    codeDiv.innerText = unicode;
                    let nameDiv = document.createElement('div');
                    nameDiv.classList.add('char-name');
                    nameDiv.innerText = charname;
                    let div = document.createElement("div");
                    div.classList.add('glyph-container');
                    if (charsvg) div.appendChild(createSVG(charsvg, ex, em));
                    div.appendChild(codeDiv);
                    div.appendChild(nameDiv);
                    target.appendChild(div);
                    allIcons.push({ code: unicode, name: charname });
                }
            });
        });
    }

}