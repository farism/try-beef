// This file contains portions of code released by Microsoft under the MIT license as part
// of an open-sourcing initiative in 2014 of the C# core libraries.
// The original source was submitted to https://github.com/Microsoft/referencesource

namespace System.Threading.Tasks
{
	abstract class TaskScheduler
	{
		private static readonly TaskScheduler s_defaultTaskScheduler = new ThreadPoolTaskScheduler() ~ delete _;

		public static TaskScheduler Default 
		{
		    get
		    {
		        return s_defaultTaskScheduler;
		    }
		}

		public static TaskScheduler Current 
		{
		    get
		    {
		        TaskScheduler current = InternalCurrent;
		        return current ?? TaskScheduler.Default;
		    }
		}

		protected static TaskScheduler InternalCurrent
		{
		    get
		    {
		        Task currentTask = Task.[Friend]InternalCurrent;
		        return ( (currentTask != null) 
		            && ((currentTask.CreationOptions & TaskCreationOptions.HideScheduler) == 0)
		            ) ? currentTask.[Friend]ExecutingTaskScheduler : null;
		    }
		}

		protected abstract void QueueTask(Task task);
		protected abstract bool TryExecuteTaskInline(Task task, bool taskWasPreviouslyQueued);

		/// <summary>
		/// Notifies the scheduler that a work item has made progress.
		/// </summary>
		protected virtual void NotifyWorkItemProgress()
		{

		}

		protected bool TryRunInline(Task task, bool taskWasPreviouslyQueued)
		{
			TaskScheduler ets = task.[Friend]ExecutingTaskScheduler;

			// Delegate cross-scheduler inlining requests to target scheduler
			if(ets != this && ets !=null) return ets.TryRunInline(task, taskWasPreviouslyQueued);

			//StackGuard currentStackGuard;
			if( (ets == null) ||
			    (task.[Friend]m_action == null) ||
			    task.[Friend]IsDelegateInvoked || 
			    task.IsCanceled
				//|| (currentStackGuard = Task.CurrentStackGuard).TryBeginInliningScope() == false
				)
			{
			    return false;
			}

			// Task class will still call into TaskScheduler.TryRunInline rather than TryExecuteTaskInline() so that 
			// 1) we can adjust the return code from TryExecuteTaskInline in case a buggy custom scheduler lies to us
			// 2) we maintain a mechanism for the TLS lookup optimization that we used to have for the ConcRT scheduler (will potentially introduce the same for TP)
			bool bInlined = false;
			//try
			{
			    task.[Friend]FireTaskScheduledIfNeeded(this);
			    bInlined = TryExecuteTaskInline(task, taskWasPreviouslyQueued);
			}
			/*finally
			{
			    currentStackGuard.EndInliningScope();
			}*/

			// If the custom scheduler returned true, we should either have the TASK_STATE_DELEGATE_INVOKED or TASK_STATE_CANCELED bit set
			// Otherwise the scheduler is buggy
			/*if (bInlined && !(task.IsDelegateInvoked || task.IsCanceled)) 
			{
			    throw new InvalidOperationException(Environment.GetResourceString("TaskScheduler_InconsistentStateAfterTryExecuteTaskInline"));
			}*/

			return bInlined;
		}

		protected void InternalQueueTask(Task task)
		{
		    //task.FireTaskScheduledIfNeeded(this);
		    this.QueueTask(task);
		}

		protected virtual bool TryDequeue(Task task)
		{
		    return false;
		}

		protected virtual bool RequiresAtomicStartTransition
		{
		    get { return true; }
		}
	}
}
