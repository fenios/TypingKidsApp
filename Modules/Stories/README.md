# Stories Module

## Purpose
Local repository of Spanish children stories used by typing and reading practice.

## Responsibilities
- Story domain model.
- Local JSON repository loaded from module resources.
- Domain model for custom stories.
- Repository protocols for custom stories and composed loading.

## Key Types
- `Story`
- `StoryRepository`
- `LocalStoryRepository` (actor)
- `CustomStory`
- `CustomStoryRepository`
- `CompositeStoryRepository`

## Notes
- Stories are stored in `Modules/Stories/Resources/stories.json`.
- Custom stories are persisted by `StoryPersistence` and merged via `CompositeStoryRepository`.

## Dependencies
- Core
