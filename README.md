# EGOGCD
    对GCD常用对象和操作的封装，如dispatch_queue_t、dispatch_group_t、dispatch_barrier_async、dispatch_semaphore_t、GCDTimer。参考了一个GCD demo，并去掉了不常用的方法，加入了自己常用的。另外这个类本来放在一个Pod私有库组件中，由于想借鉴YY的一些经验来优化多线程操作，便引入了要YYDispatchQueuePool，如有不正确之处，还请指出，一起学习。

