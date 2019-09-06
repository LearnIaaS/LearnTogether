# 配置 log

```python
#!/usr/bin/python

import os
import sys
import configparser
import logging
import traceback


def run(file_name, prefix):
	"run file_name .py"
	file_name = file_name.encode('unicode-escape').decode('string_escape')
	file_py = prefix + "/suite/" + file_name + "/"
	files = os.listdir(file_py)
	for file in files:
		if file.endswith('.py'):
			os.system("python " + file_py + "/" + file)

if __name__ == '__main__':

    print __file__
    
    logger = logging.getLogger('run_all_logger')
    logger.setLevel(logging.DEBUG)
 
    sh = logging.StreamHandler()
    sh.setLevel(logging.DEBUG)

    ch = logging.FileHandler('run_all.log')
    ch.setLevel(logging.DEBUG)
 
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    sh.setFormatter(formatter)
    ch.setFormatter(formatter)
 
    logger.addHandler(sh)    
    logger.addHandler(ch)    

    cf = configparser.ConfigParser()
    path = os.path.abspath(os.path.dirname(os.getcwd()))
    conf = path + "/config/config.conf"
    print "path:",path

    try:
        cf.read(conf)
        dic = cf.items("test")
        print dic
    except Exception as e:
        print "SSSSSSSSSSSSS:"
        result = traceback.format_exc(e)
        logger.error(result)
        sys.exit()

    pathes = []
    for it in dic:
	tmp = it[1].encode('unicode-escape').decode('string_escape')
	if tmp == 'yes' or tmp == 'YES' or tmp == '1':
            run(it[0], path)

    logger.debug('debug message')
    logger.info('info message')
    logger.warn('warn message')
    logger.error('error message')
    logger.critical('critical message')
```

