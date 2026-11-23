public class PSG_CustomIterable implements Iterable<String> {
   public List<String> lstCSVLines;
   public Iterator<String> iterator(){
      return new PSG_CustomIterator(lstCSVLines);
   }
}