
from Tkinter import *
import os
def selection_menu(options,default='',label='',title='?'):
    root = Tk()
    label = Label(root,text=label)
    label.pack()
    for number in range(len(options)):
        options[number][0] = "    %d\t%s"%(number,options[number][0])
    var = StringVar()
    def sel():
        selected = int(var.get())
        selection = "You selected the option %d"%(selected)
        label.config(text = selection)
        start_cmd(selected)
    for number in range(len(options)):
        name = options[number][0]
        R = Radiobutton(root, text=name, variable=var, value=number,
                        command=sel)
        R.pack( anchor = W )
    
    e = Entry(root,textvariable=var)
    e.pack()
    e.focus_set()
    e.insert(0,str(default))
    def comp_s(event):
        number = int(var.get())
        start_cmd(number)
    def start_cmd(num):
        cmd = options[num][1]
        print("starting ",cmd)
        root.destroy()
        os.system(cmd)
        #if os.fork() == 0:
        #    os.system(cmd)
        #else:
        #    root.destroy()
    
    e.bind('<Return>', comp_s)
    
    root.title(title)
    root.mainloop()


