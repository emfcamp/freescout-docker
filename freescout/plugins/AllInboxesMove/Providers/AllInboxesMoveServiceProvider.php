<?php

namespace Modules\AllInboxesMove\Providers;

use App\Mailbox;
use Illuminate\Support\ServiceProvider;

class AllInboxesMoveServiceProvider extends ServiceProvider
{
    /**
     * Indicates if loading of the provider is deferred.
     *
     * @var bool
     */
    protected $defer = false;

    /**
     * Boot the application events.
     *
     * @return void
     */
    public function boot()
    {
        $this->hooks();
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Module hooks.
     */
    public function hooks()
    {
        // Replace the mailbox list in the "Move Conversation" dropdown with
        // all mailboxes, regardless of what the current user has access to.
        \Eventy::addFilter('conversations.move_conv.mailboxes', function ($mailboxes) {
            return Mailbox::orderBy('name')->get();
        });
    }
}
