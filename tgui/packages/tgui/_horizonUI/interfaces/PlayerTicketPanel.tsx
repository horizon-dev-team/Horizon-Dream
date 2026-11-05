import { decodeHtmlEntities } from 'tgui-core/string';
import { useEffect, useState } from 'react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Section, Stack, TextArea } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type TicketResponse = {
  timestamp: string;
  author: string;
  message: string;
  type: 'admin' | 'mentor' | 'system' | 'legacy';
};

type PlayerTicket = {
  id: number;
  subject: string;
  status: string;
  timestamp: string;
  closed_at: string | null;
  claimed_by: string | null;
  all_responses: TicketResponse[];
  is_archived: BooleanLike;
};

type Data = {
  selected_tab: string;
  has_admin_tickets: BooleanLike;
  has_mentor_tickets: BooleanLike;
  selected_ticket: PlayerTicket | null;
};

const TicketTypeBorders: Record<string, string> = {
  admin: '1px solid hsl(0, 50%, 30%)',
  mentor: '1px solid hsl(215, 50%, 40%)',
};

const TicketTypeLabelColors: Record<string, string> = {
  admin: '#ff5f52',
  mentor: '#4d9fff',
};

const StatusColors: Record<string, string> = {
  open: 'bad',
  claimed: 'good',
  resolved: 'good',
  closed: 'label',
};

const responseTypeColor = (type: string) => {
  if (type === 'admin') {
    return 'good';
  } else if (type === 'mentor') {
    return 'average';
  } else if (type === 'system') {
    return 'label';
  }
  return 'default';
};

export const PlayerTicketPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { selected_tab, selected_ticket } = data;
  const hasAdminTickets = !!data.has_admin_tickets;
  const hasMentorTickets = !!data.has_mentor_tickets;

  const FONT_SIZE_KEY = 'playerTicketPanelFontSize';
  const FONT_SIZE_DEFAULT = 12;
  const FONT_SIZE_MIN = 9;
  const FONT_SIZE_MAX = 20;

  const [fontSize, setFontSize] = useState<number>(() => {
    const saved = localStorage.getItem(FONT_SIZE_KEY);
    return saved ? parseInt(saved, 10) : FONT_SIZE_DEFAULT;
  });

  const changeFontSize = (delta: number) => {
    setFontSize((prev) => {
      const next = Math.min(
        FONT_SIZE_MAX,
        Math.max(FONT_SIZE_MIN, prev + delta),
      );
      localStorage.setItem(FONT_SIZE_KEY, String(next));
      return next;
    });
  };

  const resetFontSize = () => {
    setFontSize(FONT_SIZE_DEFAULT);
    localStorage.setItem(FONT_SIZE_KEY, String(FONT_SIZE_DEFAULT));
  };

  const [replyText, setReplyText] = useState('');
  const selectedTicketId = selected_ticket?.id;

  useEffect(() => {
    setReplyText('');
  }, [selectedTicketId]);

  const isAdminTab = selected_tab === 'admin';
  const otherTab = isAdminTab ? 'mentor' : 'admin';
  const otherTabAvailable = isAdminTab
    ? hasMentorTickets
    : hasAdminTickets;

  const responses = selected_ticket?.all_responses ?? [];
  const isArchived = !!selected_ticket?.is_archived;

  const sendReply = () => {
    if (!replyText.trim() || !selected_ticket) {
      return;
    }
    act('reply_ticket', {
      ticket_id: selected_ticket.id,
      message: replyText,
    });
    setReplyText('');
  };

  return (
    <Window
      title="Ticket Panel"
      theme="horizon"
      width={720}
      height={780}
      buttons={
        <>
          <Button
            icon="comment"
            color="good"
            tooltip="Open the help window (F1) to send a new ticket"
            onClick={() => act('new_ticket')}
          >
            New Ticket
          </Button>
          {!!otherTabAvailable && (
            <Button
              icon="exchange-alt"
              tooltip={`Switch to your ${otherTab} ticket`}
              style={{ border: TicketTypeBorders[otherTab] }}
              onClick={() => act('select_tab', { tab: otherTab })}
            >
              Switch to {otherTab === 'admin' ? 'Admin' : 'Mentor'} Ticket
            </Button>
          )}
        </>
      }
    >
      <Window.Content style={{ fontSize: `${fontSize}px` }}>
        {selected_ticket ? (
          <Stack fill vertical>
            <Stack.Item>
              <Section>
                <Stack align="center">
                  <Stack.Item>
                    <Box
                      bold
                      style={{
                        color: TicketTypeLabelColors[selected_tab],
                      }}
                    >
                      {isAdminTab ? 'Admin Ticket' : 'Mentor Ticket'}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box
                      as="span"
                      bold
                      color={StatusColors[selected_ticket.status] || 'default'}
                    >
                      {selected_ticket.status.toUpperCase()}
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    {selected_ticket.subject && (
                      <Box
                        color="average"
                        italic
                        textAlign="right"
                        style={{
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        [{decodeHtmlEntities(selected_ticket.subject)}]
                      </Box>
                    )}
                  </Stack.Item>
                </Stack>
                <Box color="label" mt={1}>
                  Opened at {selected_ticket.timestamp}
                  {selected_ticket.closed_at &&
                    ` - Closed at ${selected_ticket.closed_at}`}
                  {selected_ticket.claimed_by &&
                    ` - Claimed by ${decodeHtmlEntities(
                      selected_ticket.claimed_by,
                    )}`}
                </Box>
                {isArchived && (
                  <Box color="average" italic mt={1}>
                    This ticket is closed and read-only.
                  </Box>
                )}
              </Section>
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section
                fill
                scrollable
                title="Conversation"
                buttons={
                  <Stack>
                    <Stack.Item>
                      <Button
                        color="transparent"
                        tooltip={`Decrease font size (current: ${fontSize}px)`}
                        onClick={() => changeFontSize(-1)}
                      >
                        A-
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        color="transparent"
                        tooltip={`Reset font size to default (${FONT_SIZE_DEFAULT}px)`}
                        onClick={resetFontSize}
                      >
                        {fontSize}px
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        color="transparent"
                        tooltip={`Increase font size (current: ${fontSize}px)`}
                        onClick={() => changeFontSize(1)}
                      >
                        A+
                      </Button>
                    </Stack.Item>
                  </Stack>
                }
              >
                {responses.length > 0 ? (
                  responses.map((response, index) => (
                    <Box key={index} mb={2}>
                      <Stack align="flex-start">
                        <Stack.Item
                          style={{ width: '60px', fontSize: '1em' }}
                          color="gray"
                        >
                          {response.timestamp || 'Unknown'}
                        </Stack.Item>
                        <Stack.Item grow>
                          <Box
                            style={{
                              whiteSpace: 'pre-wrap',
                              wordBreak: 'break-all',
                            }}
                          >
                            <Box
                              as="span"
                              color={responseTypeColor(response.type)}
                              bold={response.type !== 'system'}
                            >
                              {decodeHtmlEntities(response.author)}:{' '}
                            </Box>
                            <Box
                              as="span"
                              italic={response.type === 'system'}
                            >
                              {decodeHtmlEntities(response.message)}
                            </Box>
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  ))
                ) : (
                  <Box color="label">No messages.</Box>
                )}
              </Section>
            </Stack.Item>
            {!isArchived && (
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>
                    <TextArea
                      backgroundColor="black"
                      height="72px"
                      fluid
                      value={replyText}
                      placeholder={
                        isAdminTab
                          ? 'Reply to the admins handling this ticket...'
                          : 'Reply to the mentors handling this ticket...'
                      }
                      onChange={setReplyText}
                      style={{ border: TicketTypeBorders[selected_tab] }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Button
                          icon="paper-plane"
                          color="good"
                          fluid
                          disabled={!replyText.trim()}
                          onClick={sendReply}
                        >
                          Send Reply
                        </Button>
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button
                          icon="times"
                          color="bad"
                          fluid
                          tooltip={
                            isAdminTab
                              ? 'Close this admin ticket. You can open a new one with F1 if needed.'
                              : 'Close this mentor ticket. You can open a new one with F1 if needed.'
                          }
                          style={{ border: TicketTypeBorders[selected_tab] }}
                          onClick={() =>
                            act('close_ticket', {
                              ticket_id: selected_ticket.id,
                            })
                          }
                        >
                          Close Ticket
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}
          </Stack>
        ) : (
          <Section fill textAlign="center">
            <Stack vertical align="center" mt={4}>
              <Box fontSize="1.4em" color="label">
                You have no {isAdminTab ? 'admin' : 'mentor'} tickets this
                round.
              </Box>
              <Box color="label" mt={1}>
                Press F1 (or the New Ticket button) to contact staff.
              </Box>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
