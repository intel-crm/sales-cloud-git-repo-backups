import { sample } from './sample';

export const color = () => sample([
    'green', 'orange', 'teal', 'silver', 'yellow', 'indigo', 'grey', 'maroon', 'magenta', 'pink', 'olive'
])

export const text = () => sample([
    'Qui sint aliqua ullamco incididunt et.',
    'Sunt aliqua id mollit anim minim exercitation est.',
    'Mollit in occaecat sunt proident voluptate eiusmod reprehenderit.',
    'Ipsum esse non irure tempor est culpa pariatur adipisicing cupidatat minim occaecat culpa incididunt.',
    'Voluptate consectetur aliquip quis culpa irure eu nisi duis pariatur ipsum amet. Pariatur dolor deserunt ea consectetur. Deserunt sint labore aliqua consectetur officia fugiat id proident.'
])

export const textShort = () => sample([
    'Pariatur', 'Excepteur', 'Lorem', 'Veniam', 'Tempor', 'Proident', 'Facere', 'Consectetur', 'Quisquam',
])

export const textLong = () => 'Sit et ipsum consequat mollit. Et in nostrud Lorem cillum quis cillum amet non sint velit quis reprehenderit adipisicing. Labore eiusmod consequat sunt pariatur ut eu in qui. Do sit et irure deserunt ea cillum nulla amet eu voluptate. Amet incididunt ut ut cupidatat quis eu non veniam sit proident reprehenderit dolor exercitation.'

export const textTech = () => sample([
    'Industry', 'Technologies', 'Leading', 'Florida', 'Rebounding', 'Kansas', 'Makers', 'Chicago', 'Clemson', 'Tennessee', 'Manufacturers', 'Pseudoscience', 'Houston', 'Stocks', 'Cisco', 'Tools', 'Smart', 'Run', 'Drive', 'Usc', 'Hokies', 'Seattle', 'York', 'Home', 'Tool', 'Equipment', 'Systems', 'Basketball', 'Dallas', 'Indianapolis', 'Corporate', 'Technique', 'Drives', 'Better', 'American', 'Running', 'Michigan', 'Indiana', 'Baltimore', 'Focus', 'Midwest', 'Advantage', 'Center', 'Scientifically', 'Companies', 'Scientific', 'Phoenix', 'Record', 'Engineering', 'Game', 'Buying', 'Quarter', 'Booming', 'Longhorns', 'Cowboys', 'Syracuse', 'Firms', 'Up', 'Offense', 'California', 'Whiz', 'Upgrade', 'Sales', 'Detroit', 'Chips', 'Key', 'Notebook', 'Neuroscience', 'Hydroscience', 'Engineering school', 'Polytechnic institute', 'Metrology', 'Cyberscience', 'Sociology', 'Climatology', 'Tribology', 'Biophysics', 'Organon', 'Bionanoscience', 'Alchemical', 'Superscience', 'Technoscience', 'Geology', 'Proscience', 'Bellwethers', 'Fortran', 'Bionics', 'Multiscience', 'Antiscience', 'Phrenology', 'Architectonics', 'Ergonomics', 'N9ne', 'Scienceless', 'Systematics', 'Hydrodynamic', 'Alchemy', 'Epistemology', 'Microscopy', 'Ic', 'Theoretician', 'Interoperable', 'Psychology', 'Sciencelike', 'Geophysics', 'Cybernetics', 'University', 'Optimization', 'Scientist', 'Nonscience', 'Interoperability', 'Geoscience', 'Mcscience', 'Limnology', 'Glycoscience', 'Physicist', 'Agronomy', 'Informatics', 'Radiography', 'Metaphysics'
])

export const website = () => sample([
    'https://www.intel.com', 'https://www.google.com', 'http://www.bing.com', 'https://lwc.dev',
])