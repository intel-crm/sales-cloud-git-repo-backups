import Mocks from 'c/ipaMockData';

const generateProductCard = () => {
    let product = Mocks.Product();
    return {
        id: product.id,
        cardType: 'product',
        title: product.name,
        description: product.description,
        imageUrl: product.imageUrl,
        eyebrow: product.partner.eyebrow,
        eyebrowTagline: product.partner.eyebrowTagline,
        partnerAttributes: [], //product.partner.attributes,
        partnerId: product.partner.id,
        partnerName: product.partner.name,
        partnerByLine: product.partner.byline,
        partnerStatus: product.partner.status,
        partnerSpecialties: [], //product.partner.specialties,
        longDescription: '', //product.partner.longDescription,
        productCategories: ['XXMockCategorySame']
    };
};

const generatePartnerCard = () => {
    let partner = Mocks.Partner();
    return {
        id: partner.id,
        cardType: 'partner',
        title: partner.name,
        eyebrow: partner.eyebrow,
        eyebrowTagline: partner.eyebrowTagline,
        description: partner.description,
        imageUrl: partner.imageUrl,
        partnerId: partner.id,
        partnerName: partner.name,
        partnerByLine: partner.byline,
        partnerStatus: partner.status,
        partnerSpecialties: [], //partner.specialties,
        partnerAttributes: [], //partner.attributes,
        longDescription: '' //partner.longDescription
    };
};

const generateMemberPartnerCard = () => {
    let member = Mocks.Partner({member: true});
    return {
        id: member.id,
        cardType: 'member',
        title: member.name,
        description: member.description,
        website: member.website,
        imageUrl: member.imageUrl,
        partnerId: member.id,
        partnerStatus: member.status,
        partnerSpecialties: [], //partner.specialties,
        partnerAttributes: [], //partner.attributes,
        longDescription: '' //partner.longDescription
    };
};

let cards = { product: [], partner: [], member: [] };
while (cards.product.length < 8) {
    let card = generateProductCard();
    cards.product.push(card);
}
while (cards.partner.length < 8) {
    cards.partner.push(generatePartnerCard());
}
while (cards.member.length < 8) {
    cards.member.push(generateMemberPartnerCard());
}

export const cardsLoading = { product: [], partner: [], member: [] };
export default cards;