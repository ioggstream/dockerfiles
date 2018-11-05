from gluster import gfapi

def test_doit():
    
    # Create virtual mount
    volume = gfapi.Volume('172.20.0.2', 'gv0')
    volume.mount()
    

    try:
      # Create directory
      volume.mkdir('dir1', 0o755)
    except:
      pass

    # List directories
    print(volume.listdir('/'))
    try: 
      # Open and read file
      with volume.fopen('samefile.txt', 'r') as f:
        print(f.read())
    except: pass

    try:
    # Delete file
      volume.unlink('samefile.txt')
    except: pass

    # Create new file and write to it
    from random import randint
    for i in range(1000):
      with volume.fopen('samefile-%d.txt'%i, 'wb+') as f:
        f.write(b"12345"*100*(1<<10))
    
    # Open and read file
    #with volume.fopen('samefile.txt', 'r') as f:
    #  print(f.read())
    
    
    # Unmount the volume
    volume.umount()
    
