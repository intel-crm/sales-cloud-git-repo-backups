public with sharing class ClassFactoryManager 
{
    public ClassFactoryManager(){}

    // Return the appropriate class instance based on className
   public ClassFactory.IClassFactory newClassInstance(String className)
    {
        Type t = Type.forName(className);
        return (ClassFactory.IClassFactory) t.newInstance();
    }
}