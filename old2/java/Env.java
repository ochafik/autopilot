public class Env { 
	public static void main(String[] args) { 
		for (java.util.Enumeration e = System.getProperties().propertyNames(); e.hasMoreElements();) {
			String name = (String)e.nextElement(); 
			System.out.println(name); 
			System.out.println(System.getProperty(name)); 
			System.out.println(); 
		}
	}
}
