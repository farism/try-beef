namespace System.IO
{
	abstract class BufferedStream : Stream
	{
		protected int64 mPos;
		protected int64 mUnderlyingLength;
		protected uint8[] mBuffer ~ delete _;
		protected int64 mBufferPos = -Int32.MinValue;
		protected int64 mBufferEnd = -Int32.MinValue;
		protected int64 mWriteDirtyPos = -Int32.MinValue;
		protected int64 mWriteDirtyEnd = -Int32.MinValue;

		public override int64 Position
		{
			get
			{
				return mPos;
			}

			set
			{
				mPos = value;
			}
		}

		public override int64 Length
		{
			get
			{
				UpdateLength();
				return Math.Max(mUnderlyingLength, mWriteDirtyEnd);
			}
		}

		protected abstract void UpdateLength();
		protected abstract Result<int> TryReadUnderlying(int64 pos, Span<uint8> data);
		protected abstract Result<int> TryWriteUnderlying(int64 pos, Span<uint8> data);

		public ~this()
		{
			Flush();
		}

		public override Result<void> Seek(int64 pos, SeekKind seekKind = .Absolute)
		{
			switch (seekKind)
			{
			case .Absolute:
				mPos = pos;
			case .FromEnd:
				mPos = Length + pos;
			case .Relative:
				mPos = mPos + pos;
			}

			return .Ok;
		}

		public void MakeBuffer(int size)
		{
			delete mBuffer;
			mBuffer = new uint8[size];
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			int64 spaceLeft = (.)(mBufferEnd - mPos);
			if (mPos < mBufferPos)
				spaceLeft = 0;
			if (data.Length <= spaceLeft)
			{
				Internal.MemCpy(data.Ptr, mBuffer.Ptr + (mPos - mBufferPos), data.Length);
				mPos += data.Length;
				return data.Length;
			}

			int64 readStart = mPos;

			var data;
			if (spaceLeft > 0)
			{
				Internal.MemCpy(data.Ptr, mBuffer.Ptr + (mPos - mBufferPos), (.)spaceLeft);
				mPos += spaceLeft;
				data.RemoveFromStart((.)spaceLeft);
			}

			Try!(Flush());

			if ((mBuffer == null) || (data.Length > mBuffer.Count))
			{
				let len = Try!(TryReadUnderlying(mPos, data));
				mPos += len;
				return (.)(mPos - readStart);
			}

			var result = TryReadUnderlying(mPos, mBuffer);
			switch (result)
			{
			case .Ok(let len):
				mBufferPos = mPos;
				mBufferEnd = mPos + len;
				int readLen = Math.Min(len, data.Length);
				Internal.MemCpy(data.Ptr, mBuffer.Ptr, readLen);
				mPos += readLen;
				return (.)(mPos - readStart);
			case .Err:
				return result;
			}
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			var data;

			if ((mWriteDirtyEnd >= 0) && (mWriteDirtyEnd != mPos))
			{
				Try!(Flush());
			}

			int writeCount = 0;
			if (mWriteDirtyEnd >= 0)
			{
				int spaceLeft = (.)((mBufferPos + mBuffer.Count) - mPos);
				if (data.Length <= spaceLeft)
					writeCount = data.Length;
				else
					writeCount = spaceLeft;

				if (writeCount > 0)
				{
					Internal.MemCpy(mBuffer.Ptr + (mPos - mBufferPos), data.Ptr, writeCount);
					mPos += writeCount;
					mWriteDirtyEnd = Math.Max(mWriteDirtyEnd, mPos);
					mBufferEnd = Math.Max(mBufferEnd, mPos);
					if (writeCount == data.Length)
						return writeCount;
					data.RemoveFromStart(writeCount);
				}
			}

			Try!(Flush());

			if ((mBuffer == null) || (data.Length > mBuffer.Count))
			{
				let len = Try!(TryWriteUnderlying(mPos, data));
				mPos += len;
				writeCount += len;
				return writeCount;
			}

			mBufferPos = mPos;
			mWriteDirtyPos = mPos;
			Internal.MemCpy(mBuffer.Ptr, data.Ptr, data.Length);
			mPos += data.Length;
			mBufferEnd = mPos;
			mWriteDirtyEnd = mPos;
			writeCount += data.Length;
			return writeCount;
		}

		public override Result<void> Flush()
		{
			if (mWriteDirtyPos >= 0)
			{
				Try!(TryWriteUnderlying(mWriteDirtyPos, .(mBuffer.Ptr + (mWriteDirtyPos - mBufferPos), (.)(mWriteDirtyEnd - mWriteDirtyPos))));
				mWriteDirtyPos = -Int32.MinValue;
				mWriteDirtyEnd = -Int32.MinValue;
			}

			return .Ok;
		}

		public override Result<void> Close()
		{
			let ret = Flush();
			
			mPos = 0;
			mBufferPos = -Int32.MinValue;
			mBufferEnd = -Int32.MinValue;
			return ret;
		}
	}
}
