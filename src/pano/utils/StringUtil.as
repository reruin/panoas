
package pano.utils
{
	import flash.utils.ByteArray;
	public class StringUtil
	{

		
		/**
		*	Does a case insensitive compare or two strings and returns true if
		*	they are equal.
		* 
		*	@param s1 The first string to compare.
		*
		*	@param s2 The second string to compare.
		*
		*	@returns A boolean value indicating whether the strings' values are 
		*	equal in a case sensitive compare.	
		*
		*/			
		public static function stringsAreEqual(s1:String, s2:String, 
											caseSensitive:Boolean):Boolean
		{
			if(caseSensitive)
			{
				return (s1 == s2);
			}
			else
			{
				return (s1.toUpperCase() == s2.toUpperCase());
			}
		}
		
		/**
		*	Removes whitespace from the front and the end of the specified
		*	string.
		* 
		*/			
		public static function trim(input:String):String
		{
			return StringUtil.ltrim(StringUtil.rtrim(input));
		}

		/**
		*	Removes whitespace from the front of the specified string.
		*/	
		public static function ltrim(input:String):String
		{
			var size:Number = input.length;
			for(var i:Number = 0; i < size; i++)
			{
				if(input.charCodeAt(i) > 32)
				{
					return input.substring(i);
				}
			}
			return "";
		}

		/**
		*	Removes whitespace from the end of the specified string.
		*/	
		public static function rtrim(input:String):String
		{
			var size:Number = input.length;
			for(var i:Number = size; i > 0; i--)
			{
				if(input.charCodeAt(i - 1) > 32)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}

		/**
		*	Determines whether the specified string begins with the spcified prefix.
		* 
		*	@param input The string that the prefix will be checked against.
		*
		*	@param prefix The prefix that will be tested against the string.
		*
		*	@returns True if the string starts with the prefix, false if it does not.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function beginsWith(input:String, prefix:String):Boolean
		{			
			return (prefix == input.substring(0, prefix.length));
		}	

		/**
		*	Determines whether the specified string ends with the spcified suffix.
		* 
		*	@param input The string that the suffic will be checked against.
		*
		*	@param prefix The suffic that will be tested against the string.
		*
		*	@returns True if the string ends with the suffix, false if it does not.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function endsWith(input:String, suffix:String):Boolean
		{
			return (suffix == input.substring(input.length - suffix.length));
		}	

		/**
		*	Removes all instances of the remove string in the input string.
		* 
		*/	
		public static function remove(input:String, remove:String):String
		{
			return StringUtil.replace(input, remove, "");
		}
		
		/**
		*	Replaces all instances of the replace string in the input string
		*	with the replaceWith string.
		* 
		*	@param input The string that instances of replace string will be 
		*	replaces with removeWith string.
		*
		*	@param replace The string that will be replaced by instances of 
		*	the replaceWith string.
		*
		*	@param replaceWith The string that will replace instances of replace
		*	string.
		*
		*	@returns A new String with the replace string replaced with the 
		*	replaceWith string.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/
		public static function replace(input:String, replace:String, replaceWith:String):String
		{
			return input.split(replace).join(replaceWith);
		}
		
		
		/**
		*	Specifies whether the specified string is either non-null, or contains
		*  	characters (i.e. length is greater that 0)
		* 
		*	@param s The string which is being checked for a value
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/		
		public static function stringHasValue(s:String):Boolean
		{
			//todo: this needs a unit test
			return (s != null && s.length > 0);			
		}

		
		// 获得某级别下的四叉树
		public static function GetQuadtreeAddress( ix:int , iy:int , iz:int )
		{
			// now convert to normalized square coordinates
			// use standard equations to map into mercator projection	
			var toAll = Math.pow(2,iz);
			var x:Number = ix / toAll;
			var y:Number = iy / toAll;
			
			var quad:String = "";
			var lookup:String = "qrts";	// tl tr bl br
			/*
			 q	r
			 t	s
			*/
			for (var i:int = 0; i < iz; i++)
			{
				// make sure we only look at fractional part
				x -= Math.floor(x);
				y -= Math.floor(y);
				
				quad = quad + lookup.substr((x>=0.5?1:0) + (y>=0.5?2:0), 1);
				
				// now descend into that square
				x *= 2;
				y *= 2;
			}
			return quad;
		}
		
		 public static function removeHTMLTags(param1:String) : String
        {
            var _loc_2:* = /< *\/?br *>/gi;
            param1 = param1.replace(_loc_2, "\n");
            return param1;
        }

        public static function xmlEscapeText(param1:String) : String
        {
            param1 = param1.replace("&", "&amp;");
            param1 = param1.replace("<", "&lt;");
            param1 = param1.replace(">", "&gt;");
            return param1;
        }

  
        public static function xmlUnescapeText(param1:String) : String
        {
            param1 = param1.replace(/&amp;|&#38;/ig, "&");
            param1 = param1.replace(/&nbsp;|&#160;/ig, " ");
            param1 = param1.replace(/&copy;|&#169;/ig, "?");
            param1 = param1.replace(/&quot;|&#34;/ig, "\"");
            param1 = param1.replace(/&apos;|&#39;/ig, "\'");
            param1 = param1.replace(/&lt;|&#60;/ig, "<");
            param1 = param1.replace(/&gt;|&#62;/ig, ">");
            return param1;
        }

       
	
		// xml Untils
		public static function  xmlToVar(xml:XML, ob:Object = null) {
			if(xml)
			{
				var mr:Boolean = (ob == null)?true:false;
				if(ob == null) ob = new Object();
				var xmlList:XMLList = xml.*;
				for (var i:int = 0; i < xmlList.length(); i++) {
					if (xmlList[i] == "true") {
						ob[xmlList[i].name()] = true
					}else if(xmlList[i] == "false") {
						ob[xmlList[i].name()] = false
					}else {
						ob[xmlList[i].name()] = unescape(xmlList[i]);
					
					}
					
				}
				if(mr) return ob;
			}
		}
		
				
		public static function toObject(str:String):Object
		{
			var o:Object = new Object();
			var vars:Array = str.split("&");
			for(var i:int=0; i<vars.length; i++)
			{
				var t = vars[i].split("=");
				o[t[0]] = t[1];
			}
			return o;
		}
		
		public static function  paramToVar(paramObject:Object, varObject:Object):void 
		{
			for (var name:String in paramObject) 
			{
				if (paramObject[name] == "true") {
					varObject[name] = true;
				}else if(paramObject[name] == "false") {
					varObject[name] = false;
				}else if(isNum(paramObject[name])) {
					varObject[name] = Number(paramObject[name]);
				}else {
					varObject[name] = String(paramObject[name]);
				}
			}
		}
		
		public static function isNum(str:String):Boolean 
		{
			var numberStr:String = "1234567890.x";
			for (var i:int = 0; i < str.length; i++) {
				if (numberStr.indexOf(str.charAt(i)) <0) {
					return false;
					break;
				}
			}
			return true;
		}
		
		public static function len(str:String):Number
		{
			var ba:ByteArray = new ByteArray ();
				ba.writeMultiByte(str,"utf8");
			return ba.length;
		}
	}
}