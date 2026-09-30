import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Card, PageTitle, StateBlock } from '../components/page';
import { friendlyError } from '../lib/friendlyError';
import { listMyNotifications, markAllNotificationsRead, markNotificationRead, type AppNotification } from '../lib/registrationAccess';

/** In-app notifications: what needs your attention, newest first, each with a direct destination. */
export function NotificationsPage() {
  const navigate = useNavigate();
  const [items, setItems] = useState<AppNotification[]>();
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setError('');
    listMyNotifications(50).then(setItems).catch(err => { setError(friendlyError(err).message); setItems([]); });
  }, []);
  useEffect(load, [load]);

  const open = async (item: AppNotification) => {
    try { if (!item.read) await markNotificationRead(item.id); } catch (err) { friendlyError(err); }
    window.dispatchEvent(new Event('buhurtos:notifications-changed'));
    if (item.link) navigate(item.link);
    else load();
  };
  const markAll = async () => {
    try { await markAllNotificationsRead(); window.dispatchEvent(new Event('buhurtos:notifications-changed')); load(); }
    catch (err) { setError(friendlyError(err).message); }
  };

  const unread = (items ?? []).filter(item => !item.read).length;
  return <>
    <PageTitle title="Notifications" lead="Requests and answers that need your attention." actions={unread > 0 ? <button type="button" className="nx-btn" onClick={() => void markAll()}>Mark all as read</button> : undefined} />
    <Card>
      {items === undefined ? <StateBlock kind="loading" title="Loading notifications…" />
        : error ? <StateBlock kind="error" title="Notifications could not be loaded">{error} <button type="button" className="nx-btn" onClick={load}>Try again</button></StateBlock>
        : items.length === 0 ? <StateBlock kind="empty" title="Nothing needs your attention">
          When a fighter asks to register for your event, or an organizer answers your request, it shows up here. Meanwhile, <Link to="/events">browse events</Link>.
        </StateBlock>
        : <ul className="nx-rows">{items.map(item => <li key={item.id} className={item.read ? '' : 'unread'}>
          <div><strong>{item.read ? '' : '● '}{item.title}</strong>{item.body ? <small>{item.body}</small> : null}<small>{new Date(item.createdAt).toLocaleString()}</small></div>
          <button type="button" className="nx-btn" onClick={() => void open(item)}>{item.link ? 'Open' : 'Mark read'}</button>
        </li>)}</ul>}
    </Card>
  </>;
}
