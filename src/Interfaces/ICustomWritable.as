package Interfaces
{
	/**
	 * Adds the textvalue to a component. Makes possible to implement writable components and access them runtime via arrays or lists or other runtime build references.
	 */
	public interface ICustomWritable
	{
		function get text():String;
		function set text(value:String):void;
	}
}