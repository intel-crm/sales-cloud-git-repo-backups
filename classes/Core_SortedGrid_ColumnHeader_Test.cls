/*
Modification Log
Brian Matthews   6/5/16
*/
@isTest
public class Core_SortedGrid_ColumnHeader_Test {
    public static testMethod void sortedGrid_1 () {
        Core_SortedGrid_ColumnHeader sgHeader = new Core_SortedGrid_ColumnHeader('Name');       
        String defaultSortNullFirstLast = sgHeader.sortNullFirstLast;
        String defaultSortDirection     = sgHeader.sortDirection;
        String defaultSortField         = sgHeader.sortExpression;
        
        sgHeader.sortExpression = defaultSortField;     
        String sortIndicator    = sgHeader.sortIndicator;
        sortIndicator           = sgHeader.sortIndicator;           
    }
}