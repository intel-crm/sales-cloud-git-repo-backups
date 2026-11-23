export function BudgetAmountValidation(dataToBeChecked){
    var amount = dataToBeChecked;
    var error = '';
    if(amount<=0){
        error = 'Please enter a Budget Amount of $1 or higher (No decimal points).';
        console.log('Please enter a Budget Amount of $1 or higher (No decimal points).');
    }
    return error;
}

export function EndDateValidation(startDate,endDate){
    var error = '';
    if(startDate>endDate){
        error = 'End date cannot be Lesser than start date';
        console.log('End date cannot be Lesser than start date');
    }
    return error;
}