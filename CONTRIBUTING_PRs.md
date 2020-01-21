# Guide to contributing a pull request (PR) on a Linux host

## Quick start guide for experienced Github users

### Part A: On Github

1. Get your own Github account and login to it
2. Provide an SSH PUBLIC key to allow command line access from your local host to your Github account
    1. Select the drop-down arrow by your avatar or picture at the top-right of the black user account bar
    2. Select "Settings" on the menu
    3. Select "SSH and GPG keys" from the left-side menu
    4. Select the green "New SSH key" widget at the top right of the window
    5. Generate your SSH key pair on your local host
    6. Copy your PUBLIC key into the window and give it a meaningful title (such as the host name with the private key)
3. Back in this repository, fork this repository to your account by clicking on the "Fork" button at the top-right of this repository

### Part B: On your local host

1. Clone the repository to your local host as the origin
2. Set the remotes as "origin" for your own Github repo and "upstream" for the Raku/doc repo
3. Check out a new branch to make your changes
4. When ready to submit the PR, commit your changes with a good commit message
5. Push the new branch to your Github account

### Part C: On your Github repo

1. Submit the PR
2. Await approval or further action or guidance from someone who has a commit bit
3. If no action is seen for a day, politely ping someone on the #raku IRC channel

### For future and easier forking of public repositories

Install the Perl module [App::GitGot](https://metacpan.org/pod/App::GitGot)

## Detailed guide for newcomers

For this detailed guide we will assume you have a Github account with
user name "grace", so your on-line account is accessed at
[https://github.com/grace](https://github.com/grace).  In all the
following instructions, replace "grace" with your real Github account
name.

Go to your Github account page and select the "Repositories" tab. Make
sure you don't have one named "doc" since we are going to fork that
from the [https://github.com/raku/doc](https://github.com/raku/doc) repository.

### Part A: On Github

At this point you are ready to fork generate and provide an SSH public
key to provide command-line access from your local host to your Github
account and then fork this repository. Complete the instructions in
**Part A** above. (If you do not know how to create the SSH key pair,
then you are probably not ready for the rest of this recipe until you
can do so. Ask for help on one of the Linux mailing lists.)

If your fork was successful, you should now be in your account at page
[https://github.com/grace/doc](https://github.com/grace/doc) with the forked
version.

We can see the actual Github path for the clone step by clicking on the
green "Clone or download" button at the top right of the "<> Code" tab.
We choose the "Clone with SSH" method which shows "git@github.com:grace/doc.git".

### Part B: On your local host

1. Clone the repository to your local host as the origin

We first determine a directory where we want to clone forked repositories. For this
example we'll use "~grace/repo-forks".

```Raku
$ cd
$ mkdir repo-forks
$ cd repo-forks
```

Now do the actual cloning of our fork using the path we determined on
our Github account:

```Raku
$ git clone git@github.com:grace/doc.git
Cloning into 'doc'...
Warning: Permanently added the RSA host key for IP address '192.30.255.113' to the list of known hosts.
X11 forwarding request failed on channel 0
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 65973 (delta 0), reused 1 (delta 0), pack-reused 65968
Receiving objects: 100% (65973/65973), 19.41 MiB | 9.60 MiB/s, done.
Resolving deltas: 100% (48706/48706), done.
```

2. Set the remotes as "origin" for your own Github repo and "upstream"
   for the Raku/doc repo

CD into the new repo to check:

```Raku
$ cd doc
$ git remote -v
origin    git@github.com:grace/doc.git (fetch)
origin    git@github.com:grace/doc.git (push)
```

Add the upstream repo (we will use the https protocol for read-only access):

```Raku
$ git remote add upstream https://github.com/raku/doc
```

and notice the new remotes have been added:

```Raku
$ git remote -v
origin    git@github.com:grace/doc.git (fetch)
origin    git@github.com:grace/doc.git (push)
upstream    https://github.com/raku/doc (fetch)
upstream    https://github.com/raku/doc (push)
```

Check what branches we have:

```Raku
$ git branch
* master
```

We have only one branch at the moment, the *master* branch. The asterisk
shows we have that branch checked out, and it is the one to which we want
to make changes, but only by using a PR.

3. Check out a new branch to make your changes

We now want to start with some changes and we'll do that on our own
branch. Pick a name that is short but meaningful. We use the "-b"
option to automatically checkout the new branch.

```Raku
$ git checkout -b fix-typo
Switched to a new branch 'fix-typo'
```

Check the branches now:

```Raku
$ git branch
* fix-typo
  master
```

Now we're on the new branch as seen by the new branch name and the
asterisk by it.

For this example I've found a typo in file
"writing-docs/STYLEGUIDE.md" on line 74 where the word "exposition" I
believe should be "exposure" and then I see some other changes needed,
so I modify the whole paragraph on my local copy.

I can check the status of my change:

```Raku
$ git status
On branch fix-typo
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   writing-docs/STYLEGUIDE.md

no changes added to commit (use "git add" and/or "git commit -a")
```

I can check the differences between my branch and the master branch:

```Raku
$ git diff
diff --git a/writing-docs/STYLEGUIDE.md b/writing-docs/STYLEGUIDE.md
index 265956373..7a0573209 100644
--- a/writing-docs/STYLEGUIDE.md
+++ b/writing-docs/STYLEGUIDE.md
@@ -71,11 +71,9 @@ Try to avoid abbreviations. For example, <E2><80><9C>RHS<E2><80><9D> is short, but
 <E2><80><9C>right-hand side<E2><80><9D> is much clearer for beginners.

 In general, try to put yourself in the shoes of someone with no
-previous exposition to the language (or computer science
-altogether). Although it might seem obvious to
-you that only the first line can in fact initialize a hash, the
-documentation is targeted at people with no previous exposure to the
-language.
+previous exposure to the language or computer science. Although it
+might seem obvious to you that only the first line can in fact
+initialize a hash, the documentation is targeted at such novices.

 ### 'say' vs 'put'

```

4. When ready to submit the PR, commit your changes with a good commit message

I'm happy with my changes so I commit the changes:

```Raku
$ git commit -a -m"Use better word than 'exposition' and reword the paragraph"
[fix-typo 699343c65] Use better word than 'exposition' and reword the paragraph
 1 file changed, 3 insertions(+), 5 deletions(-)
```

The "-a" option is one of many options to "commit" instead of using file names.

5. Push the new branch to your Github account

```Raku
$ git push origin fix-typo
X11 forwarding request failed on channel 0
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 495 bytes | 495.00 KiB/s, done.
Total 4 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
remote:
remote: Create a pull request for 'fix-typo' on GitHub by visiting:
remote:      https://github.com/grace/doc/pull/new/fix-typo
remote:
To github.com:tbrowder/doc.git
 * [new branch]          fix-typo -> fix-typo
```

Now you can go back to Github to submit the PR.

### Part C: On your Github account

Back on your Github account in your fork of "doc" you should see near
the top of the "<> Code" tab some new text saying "You recently
pushed branches:" above a new yellow bar saying at its left side
"fix-typo (5 minutes ago)" and at its right side a green button saying
"Compare & pull request."

If you're satisfied with everything so far, then push the "Compare &
pull request" button.

Next pops up a window on the "raku/doc" repo where you are to complete a form
explaining in more detail the problem and solution provide as well as
possibly more details. In this instance I believe it is clear but I will
add some entries into the template:

```Raku
## The problem

The paragraph as written uses an incorrect word ("exposition" instead of
"exposure").

## Solution provided

The word was corrected and the paragraph reworded to remove redundancy
and improve the overall wording.
```

Then, at the bottom of that window I push the green button labeled
"Create pull request."

Next, the PR is created and I can either wait for action or I can
select a reviewer from the list of reviewers on the right of the
window (there may not always be a list shown). In this case I left it
alone.

## Summary

This has been a *very basic recipe* to get a new contributor through the
basic steps of contributing a PR for the "docs."

A major advantage of the PR over the bug report for you, the
contributor is you get to make the **exact** changes you think should
be made. A major advantage for the developers is they can make detailed
suggestions **before** the PR is finalized.

## Note

The example PR was actually submitted and merged (closed) as "raku/doc" PR #3174.

## References

1. [Github: About pull requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)

2. [Git documentation](https://git-scm.com/doc)
