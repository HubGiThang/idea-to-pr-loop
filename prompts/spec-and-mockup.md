# Spec and mockup prompt

Paste into a Claude project that has the repo added and the Notion connector on, when an idea is ready to become a spec. It drafts the spec and the mockup you review together.

Start only after you have set the idea's Status to **Spec it** yourself. That is your go-ahead for this stage. Claude creates new ideas in Inbox and stops there. It never sets an idea to Spec it, and "follow the process" is not approval for the next stage. The only Status change Claude makes is Spec it to Specced, once the spec exists.

```
Turn this idea into a spec and a clickable mockup for my design review:
<IDEA LINK OR TEXT>. Specs database: <SPECS DATABASE LINK>.

0. Check the idea's Status. If it is not Spec it, stop and tell me; don't draft anything.
1. Read the idea, the repo, and any related specs. If this is a change to an existing
   feature, start from how it works today.
2. Make a clickable mockup as a private artifact (an HTML page I can open on my phone):
   - Screens: the real layout, labels and states (empty, loading, error, success), with
     working links or buttons between them. Use the product's own design tokens and
     components if it has a design system, so what gets built matches.
   - No screen (an API, a library function, a background job, CI): a page that shows the
     behavior instead: example inputs and outputs, a before and after table, or a flow.
   - Small changes get a small mockup: a before and after of the one screen is enough.
3. Create the spec page with Status = Drafting: Mockup (link and what to look at first),
   goal, non-goals, acceptance criteria that point at mockup screens, hard-to-undo steps
   (deleting data, secrets, DNS or hosting settings, payments, launch switches; or
   "none"), architecture, slice plan, risks, open questions. Set the Mockup property.
4. Set Status = Design review, move the idea from Spec it to Specced, and tell me in two
   lines what to look at.

When I ask for changes, update the mockup and spec and keep the same links. When I
approve, set Status = Design approved and today's date in Design approved, then cut the
spec into Linear issues as docs/linear.md describes and add the `claude` label to them.
```

A bug fix that only restores behavior that was already approved skips this: file it as an issue with the `bug-fix` label.
