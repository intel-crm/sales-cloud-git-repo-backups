public class randomFakeClass {
    
    public static list<string> getBrand(string carCol){
        Map<string, List<string>> carNameColMp = new Map<string, List<string>>();
        carNameColMp.put('Maruti',new List<string>{'Red','Green','Blue'});
        carNameColMp.put('Kia',new List<string>{'Black','Cherry','White','Green'});
        
        List<string> brandName = new List<string>();
        
        for(string brand : carNameColMp.keySet()){
            If(carNameColMp.get(brand).contains(carCol))
                brandName.add(brand);
        }
        return brandName;
    }

}