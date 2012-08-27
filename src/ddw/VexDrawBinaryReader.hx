package ddw;

class VexDrawBinaryReader 
{
	private var data:Array<Int>;
	private var index:Int;
	private var bit:Int;
	
	public function new(data:Array<Int>) 
	{
		this.data = new Array<Int>();
	}
	
	private function ParseArray(curData:Array<Int>, curIndex:Int, curBit:Int):Array<Int>
	{
		var result = new Array<Int>();
		
		var curData = (curData != null) ? curData : this.curData;
		var curIndex = (curIndex != null) ? curIndex : this.index;		
		var curBit = (curBit != null) ? curBit : this.bit;
		
		var calc:Int = curBit > 15 ? 
			(curData[curIndex] >> (curBit - 16)) & 0xFFFF :		
			((curData[curIndex] << (16 - curBit)) | (curData[++curIndex] >>> (curBit - 16 + 32))) & 0xFFFF;
		
		var nBits:Int = (calc >> 11) + 2;
		var count:Int = calc & 0x7FF;
		
		if (curBit < 16)
		{
			curBit+=32;
		}
		curBit -= (16 + nBits);
		
		var mask:Int = Math.pow(2, nBits) - 1;
		while(count--)
		{
			if(curBit < 0) 
			{
				curBit += 32; 
				result.push( ( (curData[curIndex] << (32 - curBit)) | (curData[++curIndex] >>> curBit) ) & mask    );
			}
			else
			{
				result.push( (curData[curIndex] >>> curBit) & mask );
			}
			curBit -= nBits;
		}
		
		curBit += nBits;
		this.index = curIndex;
		this.bit = curBit;
		
		return result;
   }
   
   
   //
   //
   //prot._gBitsN = function(cm) 
   //{
   //var byte = this._nByte;
   //var dif = this._nDif;
   //var calc = dif>15 ? (cm[byte] >> (dif-16))&0xFFFF : 
   //((cm[byte]<<(16-dif))|(cm[++byte]>>>(dif-16+32))) &0xFFFF;
   //var nBits = (calc >> 11) + 2;
   //var cnt = calc & 0x7FF;
   //if(dif<16)dif+=32;
   //dif -= (16+nBits);
   //var mask = Math.pow(2, nBits)-1;
   //var nmask = ~(Math.pow(2, nBits - 1) - 1);
   //var temp = [];
   //var val = 0;
   //while(cnt--)
   //{
   //if(dif < 0) 
   //{
   //dif += 32; 
   //val= ( (cm[byte]<<(32-dif)) | (cm[++byte]>>>dif) )&mask;
   //}
   //else
   //{
   //val= (cm[byte]>>>dif)&mask;
   //}
   //dif -= nBits;
   //if(val & nmask) 
   //{
   //val |= nmask;
   //}
   //temp.push(val/20);
   //}
   //dif+= nBits;
   //this._nByte = byte;
   //this._nDif = dif;
   //return temp;
   //}
   
   
   
   
//prot.ParseBitpacked = function()
   //{
   //if(this._parsed == true || this._packed == null) return;
   //
   //var count = null;
   //var nBits = null; 
   //var df = 0;
   //var t0 = new Date().getTime(); 
   //
   //while(df<this._packed.length) 
   //{
   //var cm = this._packed[df++];
   //var tp = cm[0] >>> 24; 
   //switch(tp)
   //{
   //case 0x42: 
   //var ptCount = (cm[0] >>>13) & 0x7FF
   //this._nByte = 0;
   //this._nDif = 13;
   //
   //while(ptCount--)
   //{
   //var tps = this._gBits(cm);
   //this._paths.push( [tps, this._gBitsN(cm)] );
   //}
   //break;
   //
   //case 0x40:
   //var cols = this._gBits(cm, 0, 24);
   //for(var i = 0; i < cols.length; i++)
   //{
   //this._colors.push( cols[i]&0xFF000000 ? 
   //[cols[i]&0xFFFFFF, ((~cols[i])>>>24)/2.55]:[cols[i],100]);
   //}
   //break;
   //
   //case 0x41: 
   //var cols = this._gBits(cm, 0, 24);
   //var ws = this._gBits(cm);
   //for(var i = 0; i < ws.length; i++)
   //{
   //this._strokes.push([ws[i]/20, cols[i]&0xFFFFFF, 
   //cols[i]&0xFF000000 ? ((~cols[i])>>>24)/2.55:100] );
   //}
   //break;
   //
   //case 0x4C: 
   //var gfCount = (cm[0] >>>13) & 0x7FF
   //this._nByte = 0;
   //this._nDif = 13;
   //while(gfCount--)
   //{
   //if(this._nDif <= 0){this._nDif += 32; this._nByte++;}
   //var grtype = 
   //(cm[this._nByte]&Math.pow(2, --this._nDif))?"radial":"linear";
   //var cols = this._gBits(cm); 
   //var rats = this._gBits(cm); 
   //var ms = this._gBitsN(cm);
   //var rgbs = [];
   //var as = [];
 //for(var i = 0; i < cols.length; i++)
   //{
   //rgbs.push(cols[i]&0xFFFFFF);
   //as.push(cols[i]&0xFF000000 ? ((~cols[i])>>>24)/2.55 : 100);
   //}
   //var mx = {a:ms[0],b:ms[1],c:0,d:ms[2],e:ms[3],f:0,g:ms[4],h:ms[5],i:1};
   //this._colors.push([grtype, rgbs, as, rats, mx]);
   //}
   //break;
   //
   //case 0x32:
   //this._uses.push(this._gBits(cm, 0, 24));
   //break;
   //} 
 //} 
   //this._colors[0] = [0,0];
   //this._strokes[0] = [0,0,0];
 //trace( "=== Time to Parse === " );
   //trace( new Date().getTime()-t0 );
   //this._packed = null;
   //this._parsed = true;
   //}
}