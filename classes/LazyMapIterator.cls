public class LazyMapIterator extends LazyIterator {

    private Function mappingFunction;

    public LazyMapIterator(Iterator<Object> iterator, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
    }

    public override Object next() {
        return (Object)mappingFunction.call(iterator.next());
    }
}