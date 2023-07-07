-- | Defines a Makefile abstract syntax tree.
module Build.Drasil.Make.AST where
import Build.Drasil.Make.MakeString (MakeString)

-- * Types

-- | A Makefile is made up of Makefile rules.
newtype Makefile = M [Rule]

-- | A Makefile Rule can have comments and commands, but needs a target, dependencies, a type, and commands.
data Rule = R [MkComment] Target Dependencies Type [Command]

-- | A command is made up of 'MakeString's and command operators.
data Command = C MakeString [CommandOpts]

-- | Ignore the return code from the system.
data CommandOpts =
  IgnoreReturnCode deriving Eq

-- | Type of rule, either abstract or file-oriented.
data Type = Abstract
          | File deriving Eq


-- | A makefile Comment is a String
type MkComment = String
-- | A Makefile target is made from a 'MakeString'.
type Target = MakeString
-- | Dependencies are made up of 0 or more 'Target's.
type Dependencies = [Target]

-- * Constructors

-- | Creates a Rule which results in a file being created.
mkFile :: [MkComment] -> Target -> Dependencies -> [Command] -> Rule
mkFile c t d = R c t d File

-- | Creates an abstract Rule not associated to a specific file.
mkRule :: [MkComment] -> Target -> Dependencies -> [Command] -> Rule
mkRule c t d = R c t d Abstract

-- | Creates a Command which fails the make process if it does not return zero.
mkCheckedCommand :: MakeString -> Command
mkCheckedCommand = flip C []

-- | Creates a command which executes and ignores the return code.
mkCommand :: MakeString -> Command
mkCommand = flip C [IgnoreReturnCode]
