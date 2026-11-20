import { sample } from './sample';

export const icon = () => {
    let icons = [
        'fa-microchip',
        'fa-chart-network',
        'fa-chipsets',
        'fa-graphic-drivers',
        'fa-intel-technologies',
        'fa-barcode-alt',
        'fa-troubleshooting',
        'fa-boards-kits',
        'fa-server',
        'fa-fabric-products',
        'fa-cloud'
    ];
    return sample(icons);
}

export const sfIcon = () => {
    let sficons = [
        'utility:case',
        'utility:classic_interface',
        'utility:company',
        'utility:trailhead',
        'utility:trail',
        'utility:palette'
    ];
    return sample(sficons);
}

export const imageUrlSmall = () => {
    let images = [
        'https://www.intel.com/content/dam/www/public/us/en/images/research/16x9/labs-article-neuromorphic-research-loihi-background-16x9.jpg.rendition.intel.web.864.486.jpg',
        'https://www.intel.com/content/dam/products/catalog/global/images/1x1/devices-laptops-1x1.png.rendition.intel.web.550.550.png',
        'https://www.intel.com/content/dam/www/public/us/en/images/marquees/optane-memory-marquee-16x9.png.rendition.intel.web.480.270.png'
    ];
    return sample(images);
}