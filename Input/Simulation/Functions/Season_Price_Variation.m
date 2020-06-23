function  [price]= Season_Price_Variation(Tableoption, ContElec, timeyear, Energy_Tax_VAT, Distribution_IncTax_Fix, Energy_Tax_Var) 
Varmavirta = [7.21,6.58,6.58,6.86,6.30,6.30]';
Vihrevirta = [7.36,6.73,6.73,7.01,6.45,6.45]';
Tuulivirta = [7.51,6.88,6.88,7.16,6.60,6.60]';

if isequal(Tableoption(1:3), [1, 1, 0]');
    Optionprice = 1;
elseif isequal(Tableoption(1:3), [1, 0, 0]');
    Optionprice = 2;
elseif or(isequal(Tableoption(1:3), [1, 0, 1]'),isequal(Tableoption(1:3), [1, 1, 1]'));
    Optionprice = 3;
elseif isequal(Tableoption(1:3), [0, 1, 0]')
    Optionprice = 4;
elseif or(isequal(Tableoption(1:3), [0, 0, 1]'),isequal(Tableoption(1:3), [0, 1, 1]'));
    Optionprice = 5;
elseif isequal(Tableoption(1:3), [0, 0, 0]')
    Optionprice = 5;
end

switch(ContElec)
    case 'Varmavirta'
        MonthlyFee = 508 * 12 / (yeardays(timeyear,0) * 24) ; 
        price2 = Varmavirta(Optionprice);
    case 'Vihrevirta'
        MonthlyFee = 508 * 12 / (yeardays(timeyear,0) * 24) ; 
        price2 = Vihrevirta(Optionprice);    
    case 'Tuulivirta'
        MonthlyFee = 508 * 12 / (yeardays(timeyear,0) * 24) ; 
        price2 = Tuulivirta(Optionprice);
    otherwise
        error('Problem with the pricing system!!')
end
price = price2 * (1 + Energy_Tax_VAT / 100) + Distribution_IncTax_Fix + Energy_Tax_Var + MonthlyFee ;